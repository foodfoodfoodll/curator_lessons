import xlrd
import pandas as pd

workbook = xlrd.open_workbook('ex1.xls')    #открываем книгу
sheet = workbook.sheet_by_index(0)          #читаем первую страницу
columns = sheet.row_values(2)               #читаем строку с шапкой, записывается как массив
data = []
for rownum in range(3, sheet.nrows):        #считываем все строки под шапкой
    row = sheet.row_values(rownum)          #как массив
    data.append(row)                        #и записываем его в двумерный массив
df = pd.DataFrame(data, columns=columns)    #двумерный массив превращается в DataFrame
df.to_csv('result.csv', sep='|', index=False, header=False)   #создаётся файл, где ячейки разделены | и нет столбца с номером строки
                                                #header=False - без заголовков