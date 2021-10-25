import xlrd
import pandas as pd
import glob

data = []
headers_row = 3
columns = []
list_of_files = glob.glob(r'D:\Neoflex\куратор\*.xls')
for file in list_of_files:
    try:
        workbook = xlrd.open_workbook(file)    #открываем книгу
    except:
        log = open('log.txt', 'w')
        log.write(file)
        continue
    sheet = workbook.sheet_by_index(0)          #читаем первую страницу
    headers_row = 0
    while sheet.row_values(headers_row)[2] == '':
        headers_row+=1
    if len(columns)==0:
        columns = sheet.row_values(headers_row)               #читаем строку с шапкой, записывается как массив
        columns = columns[0:3] + columns[8:18] + columns[19:]
        for i in range(len(columns)):
            if isinstance(columns[i], str):
                columns[i] = columns[i].strip()

    for rownum in range(headers_row+1, sheet.nrows):    #считываем все строки под шапкой
        row = sheet.row_values(rownum)                  #как массив
        date = xlrd.xldate_as_tuple(row[20], 0)
        if date[2]<10:
            day='0'+str(date[2])
        else:
            day=str(date[2])
        if date[1]<10:
            month = '0' + str(date[1])
        else:
            month = str(date[1])
        year = str(date[0])
        row[20]=day + '.' + month + '.' + year

        for i in range(len(row)):
            if isinstance(row[i], str):     #если строка
                row[i] = row[i].strip()     #удалить лишние пробелы
            elif isinstance(row[i], float):
                row[i] = int(row[i])
        row = row[0:3]+row[8:18]+row[19:]
        data.append(row)                                #и записываем его в двумерный массив

df = pd.DataFrame(data, columns=columns)    #двумерный массив превращается в DataFrame
df.to_csv('result.csv', sep='|', index=False)   #создаётся файл, где ячейки разделены |
                                            # нет столбца с номером строки
                                            #header=False - без заголовков


