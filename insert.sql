COPY buffer
	FROM 'result.csv'
	DELIMITER '|'
	CSV HEADER;

--заполнение таблицы Tax
INSERT INTO Tax VALUES 
	('1', 'Includes most residential property of up to three units (such as one-, two-, and three-family homes and small stores or offices with one or two attached apartments), vacant land that is zoned for residential use, and most condominiums that are not more than three stories.'),
	('2','Includes all other property that is primarily residential, such as cooperatives and condominiums.'),
	('3','Includes property with equipment owned by a gas, telephone or electric company.'),
	('4','Includes all other properties not included in class 1,2, and 3, such as offices, factories, warehouses, garage buildings, etc.');

--заполнение таблицы Neighborhoods
INSERT INTO Neighborhoods (borough, neighborhood) 
	SELECT DISTINCT borough, neighborhood 
	FROM buffer;

--заполнение таблицы Address_info
INSERT INTO Address_info (neighborhood_id, address, apartment_number, zip_code)
	SELECT DISTINCT neighborhood_id, address, apartment_number, zip_code
		FROM buffer  JOIN neighborhoods ON buffer.neighborhood=neighborhoods.neighborhood 
											AND buffer.borough=neighborhoods.borough
		WHERE address IS NOT NULL;

--заполнение таблицы Building_info
INSERT INTO Building_info (residential_units, commercial_units, total_units, 
						   land_square, gross_square, year_built)
	SELECT DISTINCT residential_units, commercial_units, total_units, land_square_feet, gross_square_feet, year_built
	FROM buffer;

--создание временной таблицы с неповторяющимися строками
CREATE TABLE unique_buffer AS
	SELECT DISTINCT *
	FROM buffer;

--создание временной таблицы с неповторяющимися строками, которые содержат информацию только о недвижимости
CREATE TABLE unique_buffer_without_sale AS
	SELECT DISTINCT borough,
			neighborhood,
			building_class_category,
			address,
			apartment_number,
			zip_code,
			residential_units,
			commercial_units,
			total_units,
			land_square_feet,
			gross_square_feet,
			year_built,
			tax_class_at_time_of_sale
	FROM buffer;

--создание временной таблицы, содержащей дополнительно neighborhood_id, address_id и building_id
CREATE TABLE unique_buffer_without_sale_with_id AS
	SELECT unique_buffer_without_sale.*, Neighborhoods.neighborhood_id, address_id, building_id
		FROM unique_buffer_without_sale
		JOIN Neighborhoods USING (neighborhood, 
								  borough)
		JOIN Building_info ON unique_buffer_without_sale.residential_units = Building_info.residential_units 
							AND unique_buffer_without_sale.commercial_units = Building_info.commercial_units
							AND unique_buffer_without_sale.total_units = Building_info.total_units
							AND unique_buffer_without_sale.land_square_feet = Building_info.land_square
							AND unique_buffer_without_sale.gross_square_feet = Building_info.gross_square
							AND unique_buffer_without_sale.year_built = Building_info.year_built
		JOIN Address_info ON Neighborhoods.neighborhood_id=Address_info.neighborhood_id 
							AND unique_buffer_without_sale.address=Address_info.address 
							AND (unique_buffer_without_sale.apartment_number=Address_info.apartment_number 
								OR (unique_buffer_without_sale.apartment_number IS NULL 
									AND Address_info.apartment_number IS NULL))
							AND unique_buffer_without_sale.zip_code = Address_info.zip_code;


--заполнение таблицы с информацией о недвижимости
INSERT INTO Property_info (building_class_category, tax, address_id, building_id)
	SELECT building_class_category, tax_class_at_time_of_sale, address_id, building_id
	FROM unique_buffer_without_sale_with_id;

--создание таблицы временной таблицы, содержащей дополнительно ID neighborhood_id, address_id,  building_id и property_id
CREATE TABLE unique_buffer_without_sale_with_id2 AS
	SELECT unique_buffer_without_sale_with_id.*, Property_info.property_id
	FROM unique_buffer_without_sale_with_id
	JOIN Property_info ON unique_buffer_without_sale_with_id.building_class_category = Property_info.building_class_category
						AND unique_buffer_without_sale_with_id.tax_class_at_time_of_sale = Property_info.tax
						AND unique_buffer_without_sale_with_id.address_id = Property_info.address_id
						AND unique_buffer_without_sale_with_id.building_id = Property_info.building_id;							

--создание временной таблицы, содержащей исходные данные плюс ID
CREATE TABLE unique_buffer_with_sale_with_id AS
	SELECT
		unique_buffer.borough                   
		, unique_buffer.neighborhood             
		, unique_buffer.building_class_category  
		, unique_buffer.address                  
		, unique_buffer.apartment_number         
		, unique_buffer.zip_code                 
		, unique_buffer.residential_units        
		, unique_buffer.commercial_units         
		, unique_buffer.total_units              
		, unique_buffer.land_square_feet         
		, unique_buffer.gross_square_feet        
		, unique_buffer.year_built               
		, unique_buffer.tax_class_at_time_of_sale
		, unique_buffer.sale_price
		, unique_buffer.sale_date
		, unique_buffer_without_sale_with_id2.address_id
		, unique_buffer_without_sale_with_id2.building_id
		, unique_buffer_without_sale_with_id2.property_id
	FROM unique_buffer 
	JOIN unique_buffer_without_sale_with_id2
		ON unique_buffer.borough                    = unique_buffer_without_sale_with_id2.borough                   
		AND unique_buffer.neighborhood              = unique_buffer_without_sale_with_id2.neighborhood             
		AND unique_buffer.building_class_category   = unique_buffer_without_sale_with_id2.building_class_category  
		AND unique_buffer.address                   = unique_buffer_without_sale_with_id2.address                  
		AND (unique_buffer.apartment_number         = unique_buffer_without_sale_with_id2.apartment_number 
			OR (unique_buffer.apartment_number IS NULL 
				AND unique_buffer_without_sale_with_id2.apartment_number IS NULL))         
		AND unique_buffer.zip_code                  = unique_buffer_without_sale_with_id2.zip_code                 
		AND unique_buffer.residential_units         = unique_buffer_without_sale_with_id2.residential_units        
		AND unique_buffer.commercial_units          = unique_buffer_without_sale_with_id2.commercial_units         
		AND unique_buffer.total_units               = unique_buffer_without_sale_with_id2.total_units              
		AND unique_buffer.land_square_feet          = unique_buffer_without_sale_with_id2.land_square_feet         
		AND unique_buffer.gross_square_feet         = unique_buffer_without_sale_with_id2.gross_square_feet        
		AND unique_buffer.year_built                = unique_buffer_without_sale_with_id2.year_built               
		AND unique_buffer.tax_class_at_time_of_sale = unique_buffer_without_sale_with_id2.tax_class_at_time_of_sale;

--заполнение таблицы Sale
INSERT INTO Sale (price, date, property_id)
	SELECT sale_price, sale_date, property_id
	FROM unique_buffer_with_sale_with_id;

--удаление временных таблиц
DROP TABLE unique_buffer_with_sale_with_id;
DROP TABLE unique_buffer_without_sale_with_id2;
DROP TABLE unique_buffer_without_sale_with_id;
DROP TABLE unique_buffer_without_sale;
DROP TABLE unique_buffer;
DROP TABLE buffer;	




