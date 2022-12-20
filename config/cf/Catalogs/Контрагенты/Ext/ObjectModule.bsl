﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
Перем ЭтоНовый; // В переменной хранится признак нового элемента.

#Область ОбработчикиСобытий

// Процедура - обработчик события ПередЗаписью.
//
Процедура ПередЗаписью(Отказ)
	
	ЭтоНовый = ЭтоНовый();
	
КонецПроцедуры // ПередЗаписью()

// Процедура - обработчик события ПриЗаписи.
//
Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда 
		Возврат;
	КонецЕсли;
	
	// Заполним договор по умолчанию для нового контрагента, если он не заполнен.
	Если ЭтоНовый И НЕ ЭтоГруппа И НЕ ЗначениеЗаполнено(ДоговорПоУмолчанию) Тогда
		
		ЭтоНовый 					= Ложь;		
		НовыйДоговор 				= Справочники.ДоговорыКонтрагентов.СоздатьЭлемент();
		
		НовыйДоговор.Наименование 	= НСтр("ru = 'Основной договор'");
		НовыйДоговор.ВидДоговора 	= Перечисления.ВидыДоговоров.СПокупателем;
		НовыйДоговор.Владелец 		= Ссылка;
		НовыйДоговор.ВалютаРасчетов = УправлениеITОтделом8УФПовтИсп.ПолучитьОсновнуюВалюту();
		НовыйДоговор.Организация 	= УправлениеITОтделом8УФПовтИсп.ПолучитьОсновнуюОрганизацию();
		НовыйДоговор.Статус			= Перечисления.СтатусыДоговоровКонтрагентов.Действует;
		НовыйДоговор.Записать();
		
		ДоговорПоУмолчанию = НовыйДоговор.Ссылка;
		Записать();
		
	КонецЕсли;
	
КонецПроцедуры // ПриЗаписи()

// Обработчик события ПриКопировании
//
Процедура ПриКопировании(ОбъектКопирования)
	
	Если НЕ ЭтоГруппа Тогда
		БанковскийСчетПоУмолчанию = Неопределено;
		ДоговорПоУмолчанию = Неопределено;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("Структура") И Не ЭтоГруппа Тогда
		
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, ДанныеЗаполнения);
		
	ИначеЕсли ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ТелефонныйЗвонок") И Не ЭтоГруппа Тогда
		
		Наименование 		= ДанныеЗаполнения.АбонентПредставление;
		НаименованиеПолное 	= ДанныеЗаполнения.АбонентПредставление;
		Клиент				= Истина;
		
		НоваяСтрока 		= КонтактнаяИнформация.Добавить(); 
		Структура = сфпСофтФонПроСервер.сфпЗаполнитьСтруктуруПолейПоПредставлениюТелефон(ДанныеЗаполнения.АбонентКакСвязаться);
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Структура);		
		Если ПустаяСтрока(НоваяСтрока.Страна) Тогда
			НоваяСтрока.Страна = "+7";
		КонецЕсли;
		НоваяСтрока.Представление = ДанныеЗаполнения.АбонентКакСвязаться;
		НоваяСтрока.Тип = Перечисления.ТипыКонтактнойИнформации.Телефон;
		НоваяСтрока.Вид = Справочники.ВидыКонтактнойИнформации.ТелефонКонтрагента;
		
	ИначеЕсли ТипЗнч(ДанныеЗаполнения) = Тип("СправочникСсылка.ПотенциальныеКлиенты") И Не ЭтоГруппа Тогда
		
		Наименование 		= ДанныеЗаполнения.Наименование;
		НаименованиеПолное 	= ДанныеЗаполнения.Наименование;
		Клиент				= Истина;
		
		Для Каждого Строки Из ДанныеЗаполнения.КонтактнаяИнформация Цикл
			Если Строки.Вид = Справочники.ВидыКонтактнойИнформации.EmailПотенциальногоКлиента Тогда
				НоваяСтрока = КонтактнаяИнформация.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрока, Строки);
				НоваяСтрока.Вид = Справочники.ВидыКонтактнойИнформации.EmailКонтрагента;
			ИначеЕсли Строки.Вид = Справочники.ВидыКонтактнойИнформации.АдресПотенциальногоКлиента Тогда
				НоваяСтрока = КонтактнаяИнформация.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрока, Строки);
				НоваяСтрока.Вид = Справочники.ВидыКонтактнойИнформации.ФактАдресКонтрагента;
			ИначеЕсли Строки.Вид = Справочники.ВидыКонтактнойИнформации.РабочийТелефонПотенциальногоКлиента Тогда
				НоваяСтрока = КонтактнаяИнформация.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрока, Строки);
				НоваяСтрока.Вид = Справочники.ВидыКонтактнойИнформации.ТелефонКонтрагента;
			КонецЕсли;			
		КонецЦикла;
		
	КонецЕсли;
	
	ДозаполнитьПоУмолчанию();
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	МассивНепроверяемыхРеквизитов = Новый Массив;
	
	Если Не Справочники.ГруппыДоступаКонтрагентов.ИспользуютсяГруппыДоступа() Тогда
		МассивНепроверяемыхРеквизитов.Добавить("ГруппаДоступа");
	КонецЕсли;
	
	ОбщегоНазначения.УдалитьНепроверяемыеРеквизитыИзМассива(ПроверяемыеРеквизиты, МассивНепроверяемыхРеквизитов);
	
КонецПроцедуры

#КонецОбласти

#Область ПрограммныйИнтерфейс

// См. описание в комментарии к одноименной процедуре в модуле УправлениеДоступом.
//
Процедура ЗаполнитьНаборыЗначенийДоступа(Таблица) Экспорт
	
	// Логика ограничения:
	// Чтения, Изменение: объект разрешен по виду доступа ГруппыДоступаКонтрагентов.
	
	Строка = Таблица.Добавить();
	Строка.ЗначениеДоступа = Ссылка;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ДозаполнитьПоУмолчанию()
	
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;	
	
	Если Не ЗначениеЗаполнено(ГруппаДоступа) Тогда
		ГруппаДоступа = Справочники.ГруппыДоступаКонтрагентов.ГруппаДоступаПоУмолчанию();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти


#КонецЕсли