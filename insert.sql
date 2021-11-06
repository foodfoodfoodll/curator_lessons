COPY buffer
	FROM 'result.csv'
	DELIMITER '|'
	CSV HEADER;
	
--заполнение районов
INSERT INTO neighborhoods (borough, neighborhood) 
	SELECT DISTINCT borough, neighborhood 
	FROM buffer;

--заполнение налогов
INSERT INTO tax (tax) SELECT DISTINCT tax_class_at_time_of_sale FROM buffer;
UPDATE tax SET description='Includes most residential property of up to three units (such as one-, two-, and three-family homes and small stores or offices with one or two attached apartments), vacant land that is zoned for residential use, and most condominiums that are not more than three stories.'
	WHERE tax='1';
UPDATE tax SET description='Includes all other property that is primarily residential, such as cooperatives and condominiums.'
	WHERE tax='2';
UPDATE tax SET description='Includes property with equipment owned by a gas, telephone or electric company.'
	WHERE tax='3';
UPDATE tax SET description='Includes all other properties not included in class 1,2, and 3, such as offices, factories, warehouses, garage buildings, etc.'
	WHERE tax='4';

--заполнение адресов
INSERT INTO address_info (neighborhood_id, address, apartment_nubmer, zip_code)
	SELECT DISTINCT neighborhoods.id, address, apartment_number, zip_code
	FROM buffer INNER JOIN neighborhoods ON buffer.neighborhood=neighborhoods.neighborhood AND
											buffer.borough=neighborhoods.borough;

--заполнение информации о строении
INSERT INTO building_info (residential_units, commercial_units, total_units, 
						   land_square, gross_square, year_build)
	SELECT DISTINCT residential_units, commercial_units, total_units, land_square_feet, gross_square_feet, year_built
	FROM buffer;

--заполнить таблицу недвижимости
--с вью из test.sql, переписать
INSERT INTO Property_sales (building_class_category, tax_class_at_time_of_sale, id_address, id_building)
	SELECT DISTINCT building_class_category, tax_class_at_time_of_sale, Address_info.id, Building_info.id
	FROM tmp_buffer1
	INNER JOIN Address_info ON Address_info.neighborhood_id=tmp_buffer1.neighborhood_id AND
							Address_info.address=tmp_buffer1.address AND
							(Address_info.apartment_nubmer=tmp_buffer1.apartment_number OR
							(Address_info.apartment_nubmer IS NULL AND tmp_buffer1.apartment_number IS NULL))
	INNER JOIN Building_info ON Building_info.residential_units = tmp_buffer1.residential_units AND
							Building_info.commercial_units = tmp_buffer1.commercial_units AND
							Building_info.total_units = tmp_buffer1.total_units AND
							Building_info.land_square = tmp_buffer1.land_square_feet AND
							Building_info.gross_square = tmp_buffer1.gross_square_feet AND
							Building_info.year_build = tmp_buffer1.year_built;



