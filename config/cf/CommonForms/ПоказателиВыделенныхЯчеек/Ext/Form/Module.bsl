﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	// Параметры:
	//   Если передан параметр Расчет, то параметры ТабличныйДокумент и ВыделенныеОбласти не используются.
	//   Расчет - Структура - Результат функции СтандартныеПодсистемыКлиентСервер.РасчетЯчеек().
	//   ТабличныйДокумент - ТабличныйДокумент - Таблица, для которой выполняются расчеты.
	//   ВыделенныеОбласти - Массив - Области документа, которые требуется рассчитать.
	//       См. возвращаемое значение функции СтандартныеПодсистемыКлиент.ВыделенныеОбласти().
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Расчет = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "Расчет");
	Если ТипЗнч(Расчет) <> Тип("Структура") Тогда
		Расчет = УправлениеITОтделом8УФКлиентСервер.РасчетЯчеек(Параметры.ТабличныйДокумент, Параметры.ВыделенныеОбласти);
	КонецЕсли;
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, Расчет);
	
	РазрядностьЧисел    = Макс(0, Разрядность(Сумма), Разрядность(Минимум), Разрядность(Максимум));
	РазрядностьСреднего = Макс(РазрядностьЧисел, Разрядность(Среднее));
	
	ФорматЧисел = "ЧДЦ=" + Строка(РазрядностьЧисел) + "; ЧН=0";
	Элементы.Сумма.ФорматРедактирования    = ФорматЧисел;
	Элементы.Минимум.ФорматРедактирования  = ФорматЧисел;
	Элементы.Максимум.ФорматРедактирования = ФорматЧисел;
	Элементы.Среднее.ФорматРедактирования  = "ЧДЦ=" + Строка(РазрядностьСреднего) + "; ЧН=0";
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Функция Разрядность(Число)
	Возврат СтрДлина(Макс(Число,-Число)%1)-2;
КонецФункции

#КонецОбласти