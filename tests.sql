
select count(*) from buffer; --1 254 034

SELECT COUNT(*) FROM (SELECT DISTINCT * FROM buffer) AS sel; --1 225 144

--17 469 дублирующихся записей
SELECT COUNT(*) FROM
	(SELECT COUNT(*), borough, neighborhood,building_class_category,
		address,apartment_number,zip_code,residential_units,commercial_units,
		total_units,land_square_feet,gross_square_feet,year_built,
	 	tax_class_at_time_of_sale,sale_price,sale_date
		FROM buffer
		GROUP BY borough, neighborhood,building_class_category,
		address,apartment_number,zip_code,residential_units,commercial_units,
		total_units,land_square_feet,gross_square_feet,year_built,
	 	tax_class_at_time_of_sale,sale_price,sale_date)as sel
	WHERE sel.count>1;

select count(*) from neighborhoods; --268
select count(*) from address_info; --913 468
select count(*) from building_info; --313 532
select count(*) from Property_sales;
select count(*) from sale;

CREATE TEMP VIEW ubuffer AS 
	SELECT DISTINCT * FROM buffer;

--добавить id района к буфферу
CREATE TEMP VIEW tmp_buffer1 AS
	SELECT ubuffer.* , neighborhoods.id as neighborhood_id
	FROM ubuffer INNER JOIN neighborhoods ON ubuffer.neighborhood=neighborhoods.neighborhood AND
											ubuffer.borough=neighborhoods.borough;

--добавить id адреса к буфферу
CREATE TEMP VIEW tmp_buffer2 AS
	SELECT DISTINCT tmp_buffer1.* , Address_info.id as id_address
	FROM tmp_buffer1 
	INNER JOIN Address_info ON Address_info.neighborhood_id=tmp_buffer1.neighborhood_id AND
							Address_info.address=tmp_buffer1.address AND
							(Address_info.apartment_nubmer=tmp_buffer1.apartment_number OR
								(Address_info.apartment_nubmer IS NULL AND 
						 			tmp_buffer1.apartment_number IS NULL));

select count(*) from ubuffer; --1 225 144 уникальных записей
select count(*) from tmp_buffer1; --1 225 144	
select count(*) from tmp_buffer2; --1 236 996 (+11 852), записи не повторяются

drop view tmp_buffer2 CASCADE;

/*
TRUNCATE Property_sales CASCADE;
TRUNCATE address_info CASCADE;
TRUNCATE neighborhoods CASCADE;
TRUNCATE Building_info CASCADE;
*/
