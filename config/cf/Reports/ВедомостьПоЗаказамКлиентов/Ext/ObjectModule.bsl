﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	
	НастройкиОтчета = КомпоновщикНастроек.ПолучитьНастройки();
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, НастройкиОтчета, ДанныеРасшифровки);

	// Создадим и инициализируем процессор компоновки, предварительно проверим параметры
	//@skip-warning
	Если НЕ МакетКомпоновки.ЗначенияПараметров.Найти("НачалоПериода") = Неопределено 
		И НЕ МакетКомпоновки.ЗначенияПараметров.Найти("КонецПериода") = Неопределено 
		И НЕ МакетКомпоновки.ЗначенияПараметров["НачалоПериода"].Значение = Дата(1,1,1)
		И НЕ МакетКомпоновки.ЗначенияПараметров["КонецПериода"].Значение = Дата(1,1,1)
		И (МакетКомпоновки.ЗначенияПараметров["НачалоПериода"].Значение > 
			МакетКомпоновки.ЗначенияПараметров["КонецПериода"].Значение) Тогда
		
		Сообщение	 		= Новый СообщениеПользователю;
		Сообщение.Текст	 	= НСтр("ru = 'Дата начала периода не должна превышать дату окончания'");
		Сообщение.Сообщить();
		
		Возврат;
		
	КонецЕсли;

	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, , ДанныеРасшифровки, Истина);

	// Создадим и инициализируем процессор вывода результата
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);

	// Обозначим начало вывода
	ПроцессорВывода.НачатьВывод();
	ТаблицаЗафиксирована = Ложь;

	ДокументРезультат.ФиксацияСверху = 0;
	// Основной цикл вывода отчета
	Пока Истина Цикл
		// Получим следующий элемент результата компоновки
		ЭлементРезультата = ПроцессорКомпоновки.Следующий();

		Если ЭлементРезультата = Неопределено Тогда
			// Следующий элемент не получен - заканчиваем цикл вывода
			Прервать;
		Иначе
			// Зафиксируем шапку
			Если  Не ТаблицаЗафиксирована 
				  И ЭлементРезультата.ЗначенияПараметров.Количество() > 0 
				  И ТипЗнч(КомпоновщикНастроек.Настройки.Структура[0]) <> Тип("ДиаграммаКомпоновкиДанных") Тогда

				ТаблицаЗафиксирована = Истина;
				ДокументРезультат.ФиксацияСверху = ДокументРезультат.ВысотаТаблицы;

			КонецЕсли;
			// Элемент получен - выведем его при помощи процессора вывода
			ПроцессорВывода.ВывестиЭлемент(ЭлементРезультата);
		КонецЕсли;
	КонецЦикла;

	ПроцессорВывода.ЗакончитьВывод();

КонецПроцедуры

#КонецОбласти	
	
#Область СлужебныйПрограммныйИнтерфейс
	
// Настройки общей формы отчета подсистемы "Варианты отчетов".
	//
	// Параметры:
	//   Форма - УправляемаяФорма - Форма отчета.
	//   КлючВарианта - Строка - Имя предопределенного варианта отчета или уникальный идентификатор пользовательского.
	//   Настройки - Структура - см. возвращаемое значение ОтчетыКлиентСервер.ПолучитьНастройкиОтчетаПоУмолчанию().
	//
Процедура ОпределитьНастройкиФормы(Форма, КлючВарианта, Настройки) Экспорт
		
	Настройки.События.ПриСозданииНаСервере                       = Истина;
	
КонецПроцедуры
	
// Вызывается в обработчике одноименного события формы отчета после выполнения кода формы.
	//
	// Параметры:
	//   Форма - УправляемаяФорма - Форма отчета.
	//   Отказ - Передается из параметров обработчика "как есть".
	//   СтандартнаяОбработка - Передается из параметров обработчика "как есть".
	//
	// См. также:
	//   "УправляемаяФорма.ПриСозданииНаСервере" в синтакс-помощнике.
	//
Процедура ПриСозданииНаСервере(ЭтаФорма, Отказ, СтандартнаяОбработка) Экспорт
	
	Параметры                = ЭтаФорма.Параметры;
	
	Если Параметры.Свойство("ПараметрКоманды") Тогда		
		ЭтаФорма.ФормаПараметры.Отбор.Вставить("ЗаказКлиента", Параметры.ПараметрКоманды);
	КонецЕсли;
		
КонецПроцедуры
	
#КонецОбласти

#КонецЕсли