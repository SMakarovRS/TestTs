﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("ПрефиксКартинок") Тогда
		ПрефиксКартинок = НРег(Параметры.ПрефиксКартинок);
		Если ПрефиксКартинок = "вдж" Тогда
			Элементы.РазмерКартинки.Видимость = Истина;
			РазмерКартинки 	= 16;
			ПрефиксКартинок = "вдж16"
		КонецЕсли;	
	Иначе
		ПрефиксКартинок = "сст";
	КонецЕсли;
	
	ЗаполнитьТаблицуИзображений();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормы

&НаКлиенте
Процедура РазмерКартинкиПриИзменении(Элемент)
	
	Если РазмерКартинки > 0 Тогда
		ПрефиксКартинок = "вдж" + Строка(РазмерКартинки);
	    ЗаполнитьТаблицуИзображений();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыТаблица

&НаКлиенте
Процедура ТаблицаВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Если Элементы.Таблица.ТекущиеДанные <> Неопределено Тогда
		ОповеститьОВыборе(Элементы.Таблица.ТекущиеДанные.Картинка);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Выбрать(Команда)
	
	Если Элементы.Таблица.ТекущиеДанные <> Неопределено Тогда
		ОповеститьОВыборе(Элементы.Таблица.ТекущиеДанные.Картинка);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьТаблицуИзображений()
	
	Таблица.Очистить(); 
	СтрДлинаПрефиксКартинок = СтрДлина(ПрефиксКартинок);
	Для каждого Картинка Из Метаданные.ОбщиеКартинки Цикл
		Если Лев(Картинка.Имя, СтрДлинаПрефиксКартинок) = ПрефиксКартинок Тогда
			НоваяСтрока 				= Таблица.Добавить();
			НоваяСтрока.Картинка 		= БиблиотекаКартинок[Картинка.Имя];
			НоваяСтрока.Наименование 	= Картинка.Синоним;
		КонецЕсли;
	КонецЦикла;
	Таблица.Сортировать("Наименование");
	
КонецПроцедуры

#КонецОбласти