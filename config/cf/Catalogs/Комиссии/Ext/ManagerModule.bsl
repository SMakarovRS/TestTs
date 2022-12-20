﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область ПрограммныйИнтерфейс

Функция ОписаниеДокументовСКомиссиями(МетаданныеДокументов)
	
	ДокументыСКомиссиями = Новый Соответствие;
	
	Для каждого МетаданныеДокумента Из МетаданныеДокументов Цикл
				
		ДокументыСКомиссиями.Вставить(МетаданныеДокумента.Имя, МетаданныеДокумента.Синоним);
		
	КонецЦикла;
	
	Возврат ДокументыСКомиссиями;
	
КонецФункции

Функция ДокументыСКомиссиями() Экспорт
	
	МетаданныеДокументов = Новый Массив;
	МетаданныеДокументов.Добавить(Метаданные.Документы.Инвентаризация);
	МетаданныеДокументов.Добавить(Метаданные.Документы.ОкончаниеОбслуживания);
	МетаданныеДокументов.Добавить(Метаданные.Документы.Перемещение);
	МетаданныеДокументов.Добавить(Метаданные.Документы.Поступление);
	МетаданныеДокументов.Добавить(Метаданные.Документы.Списание);
	Возврат ОписаниеДокументовСКомиссиями(МетаданныеДокументов);
	
КонецФункции

Функция КомиссияИспользуетсяВДокументах(Комиссия) Экспорт
	
	ДокументыСКомиссиями		= ДокументыСКомиссиями();
	
	Схема						= Новый СхемаЗапроса;
	ПакетЗапросовСхемыЗапросов	= Схема.ПакетЗапросов[0];
	Операторы					= ПакетЗапросовСхемыЗапросов.Операторы;
	
	ПервыйОператор = Истина;
	Для каждого ОписаниеДокумента Из ДокументыСКомиссиями Цикл
		
		ОператорТаблицы = ?(ПервыйОператор, Операторы[0], Операторы.Добавить());
		ОператорТаблицы.Источники.Добавить("Документ." + ОписаниеДокумента.Ключ, ОписаниеДокумента.Ключ);
		ОператорТаблицы.ТипОбъединения = ТипОбъединенияСхемыЗапроса.ОбъединитьВсе;
		ОператорТаблицы.ВыбираемыеПоля.Добавить(ОписаниеДокумента.Ключ + ".Ссылка");
		ОператорТаблицы.Отбор.Добавить(ОписаниеДокумента.Ключ + ".Комиссия = &Комиссия И " + ОписаниеДокумента.Ключ + ".Комиссия <> ЗНАЧЕНИЕ(Справочник.Комиссии.ПустаяСсылка)");
		
		ПервыйОператор = Ложь;
		
	КонецЦикла;
	
	Запрос = Новый Запрос(Схема.ПолучитьТекстЗапроса());
	Запрос.УстановитьПараметр("Комиссия", Комиссия);
	
	Возврат НЕ Запрос.Выполнить().Пустой();
	
КонецФункции

Функция ПодписиКомиссииМассивом(Комиссия) Экспорт
	
	РазмерКомиссии = 0;
	Если ЗначениеЗаполнено(Комиссия) Тогда
		
		РазмерКомиссии = Комиссия.ПодписиКомиссии.Количество();
		
	КонецЕсли;
	
	СтруктураКомиссии = Новый Структура;
	СтруктураКомиссии.Вставить("ПодписьПредседателя", Неопределено);
	СтруктураКомиссии.Вставить("РазмерКомиссии", РазмерКомиссии);
	СтруктураКомиссии.Вставить("ПодписиКомиссии", Новый Массив);
	
	Если РазмерКомиссии > 0 Тогда
		
		Для каждого СтрокаОписанияПодписи Из Комиссия.ПодписиКомиссии Цикл
			
			Если СтрокаОписанияПодписи.ЭтоПодписьПредседателяКомиссии Тогда
				
				СтруктураКомиссии.ПодписьПредседателя = СтрокаОписанияПодписи.ПодписьЧленаКомиссии;
				
			КонецЕсли;
			
			СтруктураКомиссии.ПодписиКомиссии.Добавить(СтрокаОписанияПодписи.ПодписьЧленаКомиссии);
			
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат СтруктураКомиссии;
	
КонецФункции

Процедура РасформироватьКомиссииПриУвольнении(ДополнительныеСвойства, Отказ) Экспорт
	
	ТаблицаКомиссийКРасформированию = ДополнительныеСвойства.ТаблицыДляДвижений.ТаблицаКомиссийКРасформированию;
	Для каждого СтрокаТаблицы Из ТаблицаКомиссийКРасформированию Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.Комиссия) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		ПодписьОбъект = СтрокаТаблицы.Комиссия.ПолучитьОбъект();
		Попытка
			
			ПодписьОбъект.Заблокировать();
			ПодписьОбъект.КомиссияРасформирована = Истина;
			ПодписьОбъект.Записать();
			
		Исключение
			
			Отказ = Истина;
			ВызватьИсключение;
			
		КонецПопытки;
		
	КонецЦикла;
	
	
КонецПроцедуры

// СтандартныеПодсистемы.ВерсионированиеОбъектов

// Определяет настройки объекта для подсистемы ВерсионированиеОбъектов.
//
// Параметры:
// Настройки - Структура - настройки подсистемы.
Процедура ПриОпределенииНастроекВерсионированияОбъектов(Настройки) Экспорт

КонецПроцедуры
// Конец СтандартныеПодсистемы.ВерсионированиеОбъектов

#КонецОбласти

#Область ИнтерфейсПечати

Функция ПечатьПриказа(МассивОбъектов, ОбъектыПечати, Макет) Экспорт
	
	СтруктураЗаполнения = Новый Структура;
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ПФ_XML_ПриказОСозданииКомиссии";
	
	ПервыйСправочник = Истина;
	
	Для Каждого ТекущийОбъект Из МассивОбъектов Цикл
		
		Если Не ПервыйСправочник Тогда
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			СтруктураЗаполнения.Очистить();
		КонецЕсли;
		
		ПервыйСправочник = Ложь;
		
		НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	Комиссии.Ссылка,
		|	Комиссии.Код КАК Номер,
		|	Комиссии.Организация,
		|	Комиссии.Организация.Префикс КАК Префикс,
		|	Комиссии.ДатаПодписаниеПриказа,
		|	Комиссии.КомиссияФункционируетПо,
		|	Комиссии.ПодписиКомиссии.(
		|		ЭтоПодписьПредседателяКомиссии КАК ЭтоПредседатель,
		|		ПодписьЧленаКомиссии.РасшифровкаПодписи КАК ПодписьЧленаКомиссии,
		|		ПодписьЧленаКомиссии.Должность КАК Должность
		|	) КАК СоставКомиссии
		|ИЗ
		|	Справочник.Комиссии КАК Комиссии
		|ГДЕ
		|	Комиссии.Ссылка В(&МассивОбъектов)
		|
		|УПОРЯДОЧИТЬ ПО
		|	ЭтоПредседатель УБЫВ";
		
		Запрос.УстановитьПараметр("МассивОбъектов", ТекущийОбъект.Ссылка);
		Шапка = Запрос.Выполнить().Выбрать();
		
		ПервыйДокумент = Истина;
		
		Пока Шапка.Следующий() Цикл
			
			НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
			
			ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
			
			ПредставлениеПриказа = НСтр("ru ='Приказ №%1 от %2'");
			НомерДокумента = ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(Шапка.Номер, Шапка.Префикс);
			ПредставлениеПриказа = СтрШаблон(ПредставлениеПриказа, НомерДокумента, Формат(Шапка.ДатаПодписаниеПриказа, "ДЛФ=DD"));
			СтруктураЗаполнения.Вставить("ПредставлениеПриказа", ПредставлениеПриказа);
			СтруктураЗаполнения.Вставить("ОписаниеПриказа", НСтр("ru ='о создании комиссии по предприятию:'"));
			СтруктураЗаполнения.Вставить("НазначениеКомиссии", НСтр("ru ='с целью списания товаров, назначается постоянно действующая комиссия в составе:'"));
			СведенияОбОрганизации = УправлениеITОтделом8УФ.СведенияОЮрФизЛице(Шапка.Организация, Шапка.ДатаПодписаниеПриказа);
			ПредставлениеОрганизации = УправлениеITОтделом8УФ.ОписаниеОрганизации(СведенияОбОрганизации, "ПолноеНаименование");
			СтруктураЗаполнения.Вставить("Организация", ПредставлениеОрганизации);
			
			ОбластьМакета.Параметры.Заполнить(СтруктураЗаполнения);
			ТабличныйДокумент.Вывести(ОбластьМакета);
			
			ОбластьМакета = Макет.ПолучитьОбласть("ЧленыКомиссии");
			
			НомерЧленаКомиссии = 1;
			СоставКомиссии = Шапка.СоставКомиссии.Выбрать();
			Пока СоставКомиссии.Следующий() Цикл 
				Если СоставКомиссии.ЭтоПредседатель Тогда
					СтруктураЗаполнения.Вставить("ДолжностьПредседателяКомиссии", СоставКомиссии.Должность);
					СтруктураЗаполнения.Вставить("ФИОПредседателяКомиссии", СоставКомиссии.ПодписьЧленаКомиссии);
				Иначе
					НомерВФормате = Формат(НомерЧленаКомиссии, "ЧРД=; ЧРГ=; ЧН=0; ЧГ=");				
					СтруктураЗаполнения.Вставить("ДолжностьЧленаКомиссии" + НомерВФормате, СоставКомиссии.Должность);
					СтруктураЗаполнения.Вставить("ФИОЧленаКомиссии" + НомерВФормате, СоставКомиссии.ПодписьЧленаКомиссии);
					НомерЧленаКомиссии = НомерЧленаКомиссии + 1;
				КонецЕсли;
			КонецЦикла;
			ОбластьМакета.Параметры.Заполнить(СтруктураЗаполнения);
			ТабличныйДокумент.Вывести(ОбластьМакета);
			
			ОбластьМакета = Макет.ПолучитьОбласть("Подвал");
			СтруктураЗаполнения.Вставить("ОбязанностиКомиссииЗаголовок",  НСтр("ru ='Постоянно действующая комиссия осуществляет свою работу в соответствии с учетной политикой организации и утверждается текущим приказом.'"));
			СтруктураЗаполнения.Вставить("СрокДействияКомиссииЗаголовок", НСтр("ru ='Персональный состав постоянно действующей комиссии назначается сроком до:'"));
			СтруктураЗаполнения.Вставить("КомиссияФункционируетПО", Формат(Шапка.КомиссияФункционируетПо, "ДЛФ=DD"));
			
			СтруктураРуководители = УправлениеITОтделом8УФ.ОтветственныеЛицаОрганизационнойЕдиницы(Шапка.Организация, Шапка.ДатаПодписаниеПриказа); 
			СтруктураЗаполнения.Вставить("ДолжностьРуководителя", СтруктураРуководители.РуководительДолжность);
			СтруктураЗаполнения.Вставить("ФИОРуководителя", СтруктураРуководители.ФИОРуководителя); 
			
			ОбластьМакета.Параметры.Заполнить(СтруктураЗаполнения);
			ТабличныйДокумент.Вывести(ОбластьМакета);
			
			УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, Шапка.Ссылка);
			
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат ТабличныйДокумент;
	
КонецФункции

Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	ПечатнаяФорма = УправлениеПечатью.СведенияОПечатнойФорме(КоллекцияПечатныхФорм, "ПриказОСозданииКомиссии");
	Если ПечатнаяФорма <> Неопределено Тогда
		
		ПолныйПутьКМакету				= "Справочник.Комиссии.ПФ_XML_ПриказОСозданииКомиссии";
		Макет							= УправлениеПечатью.МакетПечатнойФормы(ПолныйПутьКМакету);
		ПечатнаяФорма.ТабличныйДокумент = ПечатьПриказа(МассивОбъектов, ОбъектыПечати, Макет);
		ПечатнаяФорма.СинонимМакета		= НСтр("ru = 'Приказ о создании комиссии'");
		ПечатнаяФорма.ПолныйПутьКМакету = ПолныйПутьКМакету;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьКомандыПечати(КомандыПечати) Экспорт
	
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Идентификатор = "ПриказОСозданииКомиссии";
	КомандаПечати.Представление = НСтр("ru = 'Приказ о создании комиссии'");
	КомандаПечати.СписокФорм = "ФормаЭлемента,ФормаСписка";
	КомандаПечати.Порядок = 1;
	
КонецПроцедуры

#КонецОбласти
		
#КонецЕсли