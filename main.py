import xlrd
import pandas as pd
import glob

data = []
Sale = []
Property_info = []
Building_class = []
Address_info = []
Building_info = []
Neighborhoods = set()
headers_row = 4
list_of_files = glob.glob(r'D:\Neoflex\куратор\*.xls')
new_index=0
for file in list_of_files:
    try:
        workbook = xlrd.open_workbook(file)    #открываем книгу
    except:
        log = open('log.txt', 'w')
        log.write(file)
        continue
    sheet = workbook.sheet_by_index(0)          #читаем первую страницу
    """
    columns = sheet.row_values(headers_row)               #читаем строку с шапкой, записывается как массив
    for i in range(len(columns)):
        if isinstance(columns[i], str):
            columns[i] = columns[i].strip()
    """
    for rownum in range(headers_row+1, sheet.nrows):    #считываем все строки под шапкой
        row = sheet.row_values(rownum)                  #как массив
        date = xlrd.xldate_as_tuple(row[20], 0)
        if date[2]>10:
            day='0'+str(date[2])
        else:
            day=str(date[2])
        if date[1]>10:
            month = '0' + str(date[2])
        else:
            month = str(date[2])
        year = str(date[0])
        row[20]=day + '.' + month + '.' + year
        for i in range(len(row)):
            if isinstance(row[i], str):     #если строка
                row[i] = row[i].strip()     #удалить лишние пробелы
            elif isinstance(row[i], float):
                row[i] = int(row[i])

        row.insert(0, new_index + rownum - headers_row)
        data.append(row)                                #и записываем его в двумерный массив
        Neighborhoods.add(row[2])
    new_index = len(data)
        #building_class_tmp = [row[7], row[3]]
        #if building_class_tmp not in Building_class:
            #Building_class.append(building_class_tmp)

Neighborhoods = list(Neighborhoods)         # добавила индекс к районам
for i in range(len(Neighborhoods)):
    Neighborhoods[i]=[i+1, Neighborhoods[i]]

for row in data:
    for i in Neighborhoods:
        if i[1]==row[2]:
            row[2]=i[0]
    Address_info.append([row[0], row[2], row[9], row[10], row[11]])
    Building_info.append([row[0],row[12],row[13],row[14],row[15],row[16], row[17]])
    Property_info.append([row[0], row[1], row[5],row[6], row[3], row[8], row[4], row[18], row[18], row[7], row[0], row[0]])
    Sale.append([row[0],row[20], row[21], row[0]])

"""
    for по каждой строке даты
    заполняем сначала крайние, после центральную
    если в центральной есть значение из крайней, то заменить его на индекс из крайней, типа id

    или заполнить крайнице таблицы, а после центральную заменять по поиску
    если в дате район == району из нейтборхуд, то район в дате = индекс того района
"""


#df = pd.DataFrame(data, columns=columns)    #двумерный массив превращается в DataFrame
#df.to_csv('result.csv', sep='|', index=False)   #создаётся файл, где ячейки разделены |
                                            # нет столбца с номером строки
                                            #header=False - без заголовков

dNeighborhoods = pd.DataFrame(Neighborhoods)
dNeighborhoods.to_csv('Neighborhoods.csv', sep='|', index=False, header=False)
#dBuilding_class = pd.DataFrame(Building_class)
#dBuilding_class.to_csv('Building_class.csv', sep='|', index=False, header=False)
dSale = pd.DataFrame(Sale)
dSale.to_csv('Sale.csv', sep='|', index=False, header=False)
dProperty_info = pd.DataFrame(Property_info)
dProperty_info.to_csv('Property_info.csv', sep='|', index=False, header=False)
dAddress_info = pd.DataFrame(Address_info)
dAddress_info.to_csv('Address_info.csv', sep='|', index=False, header=False)
dBuilding_info = pd.DataFrame(Building_info)
dBuilding_info.to_csv('Building_info.csv', sep='|', index=False, header=False)


# у билдинг класса одного типа бывают разные налоги

