﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	ТипЗаписиИндекс = 0;
	Если Запись.ТипСобытия = Перечисления.ТипыСобытийЖурналаРаботыСМобильнымиКлиентами.Предупреждение Тогда
		ТипЗаписиИндекс = 1;

	ИначеЕсли Запись.ТипСобытия = Перечисления.ТипыСобытийЖурналаРаботыСМобильнымиКлиентами.Ошибка Тогда
		ТипЗаписиИндекс = 2;

	КонецЕсли;

КонецПроцедуры

#КонецОбласти
