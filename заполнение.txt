COPY buffer
FROM 'result.csv'
DELIMITER '|'
CSV HEADER;

--заполнение районов
INSERT INTO neighborhoods (neighborhood) SELECT DISTINCT neighborhood FROM buffer;

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
INSERT INTO address_info (borough, neighborhood_id, address, apartment_nubmer, zip_code)
	SELECT borough, neighborhoods.id, address, apartment_number, zip_code
	FROM buffer INNER JOIN neighborhoods ON buffer.neighborhood=neighborhoods.neighborhood;

--заполнение информации о строении
INSERT INTO building_info (residential_units, commercial_units, total_units, 
						   land_square, gross_square, year_build)
	SELECT residential_units, commercial_units, total_units, land_square_feet, gross_square_feet, year_built
	FROM buffer;

--информация о недвижимости (не работает)
INSERT INTO Property_sales (building_class_category, tax_class_at_time_of_sale, id_address, id_building)
	SELECT building_class_category, tax_class_at_time_of_sale, Address_info.id--, Building_info.id
	FROM buffer
	INNER JOIN Address_info ON Address_info.borough=buffer.borough AND
							Address_info.address=buffer.address AND
							Address_info.apartment_nubmer=buffer.apartment_number
	INNER JOIN Building_info ON Building_info.residential_units = buffer.residential_units AND
							Building_info.commercial_units = buffer.commercial_units AND
							Building_info.total_units = buffer.total_units AND
							Building_info.land_square = buffer.land_square_feet AND
							Building_info.gross_square = buffer.gross_square_feet AND
							Building_info.year_build = buffer.year_built

VACUUM;