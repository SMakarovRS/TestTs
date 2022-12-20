﻿
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Тогда
	
#Область ПрограммныйИнтерфейс

Процедура ЗаполнитьВидыДелПоУмолчанию(Знач Пользователь) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	СтолбцыПоУмолчанию = ТаблицаСтолбцыПоУмолчанию();
	
	СортировкаПоСроку = Новый ТаблицаЗначений;
	СортировкаПоСроку.Колонки.Добавить("Имя");
	СортировкаПоСроку.Колонки.Добавить("Представление");
	СортировкаПоСроку.Колонки.Добавить("Направление");
	ДобавитьСтрокуСортировке(СортировкаПоСроку, НСтр("ru = 'Срок'"));
	
	СортировкаПоДатеСледующегоОбзора = Новый ТаблицаЗначений;
	СортировкаПоДатеСледующегоОбзора.Колонки.Добавить("Имя");
	СортировкаПоДатеСледующегоОбзора.Колонки.Добавить("Представление");
	СортировкаПоДатеСледующегоОбзора.Колонки.Добавить("Направление");
	ДобавитьСтрокуСортировке(СортировкаПоДатеСледующегоОбзора, "ДатаСледующегоОбзора", НСтр("ru = 'Следующий обзор'"));
	
	ГруппировкаПоСроку = Новый ТаблицаЗначений;
	ГруппировкаПоСроку.Колонки.Добавить("Имя");
	ГруппировкаПоСроку.Колонки.Добавить("Представление");
	ГруппировкаПоСроку.Колонки.Добавить("Направление");
	ДобавитьСтрокуСортировке(ГруппировкаПоСроку, НСтр("ru = 'Срок'"));
	
	// INBOX (Входящие)
	СтрокаОтбор = 
		"МассивУсловий.Добавить(""Дела.Ссылка В ИЕРАРХИИ (&СправочникиДелаInbox) И Дела.Ссылка <> &СправочникиДелаInbox"");
		|Запрос.УстановитьПараметр(""СправочникиДелаInbox"", Inbox);";
	ЗаписатьВидДела(Пользователь, СтолбцыПоУмолчанию,,,СтрокаОтбор, "Inbox", , НСтр("ru = 'Входящие'"), 0, 1, ,
		БиблиотекаКартинок.сстВходящие);
	
	// All (Все дела)
	СтрокаОтбор = "";
	ЗаписатьВидДела(Пользователь, СтолбцыПоУмолчанию,,,СтрокаОтбор, "All",,НСтр("ru = 'Все дела'"), 0, 2,,
		БиблиотекаКартинок.сстВсеДела);
	
	// Favourites (Избранное)
	СтрокаОтбор = 
		"МассивУсловий.Добавить(""Дела.Избранное = Истина"");";
	ЗаписатьВидДела(Пользователь, СтолбцыПоУмолчанию,,,СтрокаОтбор, "Favourites",, НСтр("ru = 'Избранное'"), 0, 3, Ложь,
		БиблиотекаКартинок.сстИзбранное);
	
	// ВЕТКА ВИДЫ
	Main = ЗаписатьГруппуВидаДела(Пользователь, "Main",, НСтр("ru = 'Виды'"), 4, БиблиотекаКартинок.сстВиды);
	
	// Goals (Цели)
	СтрокаОтбор = 
		"МассивУсловий.Добавить(""Дела.Ссылка В (ВЫБРАТЬ Д.Ссылка КАК Ссылка ИЗ Справочник.Дела КАК Д ГДЕ Д.ВидЦели <> Значение(Перечисление.ВидЦелиДела.Нет))"");";
	ЗаписатьВидДела(Пользователь, СтолбцыПоУмолчанию,,,СтрокаОтбор, "Goals",Main, НСтр("ru = 'Цели'"), 0, 5,Истина,
		БиблиотекаКартинок.сстЦель,,Истина);
	
	// Review (Обзор)
	СтолбцыОбзора = Новый ТаблицаЗначений;
	СтолбцыОбзора.Колонки.Добавить("Имя");
	СтолбцыОбзора.Колонки.Добавить("Представление");
	ДобавитьСтрокуСтолбцам(СтолбцыОбзора, "Тема");
	ДобавитьСтрокуСтолбцам(СтолбцыОбзора, "Срок");
	ДобавитьСтрокуСтолбцам(СтолбцыОбзора, "ОбзорКаждыеСтрокой", НСтр("ru = 'Обзор каждые'"));
	ДобавитьСтрокуСтолбцам(СтолбцыОбзора, "ДатаСледующегоОбзора", НСтр("ru = 'Следующий обзор'"));
	ДобавитьСтрокуСтолбцам(СтолбцыОбзора, "ДатаПоследнегоОбзора", НСтр("ru = 'Последний обзор'"));
	ДобавитьСтрокуСтолбцам(СтолбцыОбзора, "Напоминание");
	ДобавитьСтрокуСтолбцам(СтолбцыОбзора, "Отметка");
	ДобавитьСтрокуСтолбцам(СтолбцыОбзора, "Избранное");
	СтрокаОтбор = 
		"МассивУсловий.Добавить(""Дела.Обзор = ИСТИНА И Дела.ДатаСледующегоОбзора <= КОНЕЦПЕРИОДА(&ТекущаяДата, ДЕНЬ)"");";
	ЗаписатьВидДела(Пользователь, СтолбцыОбзора, СортировкаПоДатеСледующегоОбзора,,СтрокаОтбор, "Review",Main,
		НСтр("ru = 'Обзор'"), 0, 6, Истина,БиблиотекаКартинок.сстОбзор,,Истина);
	
	// Today (Сегодня)
	СтрокаОтбор = 
		"МассивУсловий.Добавить(""Дела.Срок <> ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0) И Дела.Срок >= НАЧАЛОПЕРИОДА(&ТекущаяДата, ДЕНЬ) И Дела.Срок <= КОНЕЦПЕРИОДА(&ТекущаяДата, ДЕНЬ)"");";
	ЗаписатьВидДела(Пользователь, СтолбцыПоУмолчанию, СортировкаПоСроку,,СтрокаОтбор, "Today",Main,
		НСтр("ru = 'Сегодня'"), 0, 7, Ложь,БиблиотекаКартинок.сстСегодня);
	
	// Tomorrow (Завтра)
	СтрокаОтбор = 
		"МассивУсловий.Добавить(""Дела.Срок <> ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0) И Дела.Срок >= ДОБАВИТЬКДАТЕ(НАЧАЛОПЕРИОДА(&ТекущаяДата, ДЕНЬ), ДЕНЬ, 1) И Дела.Срок <= ДОБАВИТЬКДАТЕ(КОНЕЦПЕРИОДА(&ТекущаяДата, ДЕНЬ), ДЕНЬ, 1)"");";
	ЗаписатьВидДела(Пользователь, СтолбцыПоУмолчанию, СортировкаПоСроку,,СтрокаОтбор, "Tomorrow",Main,
		НСтр("ru = 'Завтра'"), 0, 8, Ложь,БиблиотекаКартинок.сстЗавтра);
	
	// ThisWeek (Эта неделя)
	СтрокаОтбор = 
		"МассивУсловий.Добавить(""Дела.Срок <> ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0) И Дела.Срок >= НАЧАЛОПЕРИОДА(&ТекущаяДата, НЕДЕЛЯ) И Дела.Срок <= КОНЕЦПЕРИОДА(&ТекущаяДата, НЕДЕЛЯ)"");";
	ЗаписатьВидДела(Пользователь, СтолбцыПоУмолчанию, СортировкаПоСроку,ГруппировкаПоСроку,СтрокаОтбор, "ThisWeek",Main,
		НСтр("ru = 'Эта неделя'"), 0, 9, Ложь,БиблиотекаКартинок.сстНеделя);
	
	// Expired (Просрочено)
	СтрокаОтбор = 
		"МассивУсловий.Добавить(""Дела.Срок <> ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0) И ВЫБОР КОГДА Дела.ИспользоватьВремя ТОГДА Дела.Срок < &ТекущаяДата ИНАЧЕ НАЧАЛОПЕРИОДА(Дела.Срок, ДЕНЬ) < НАЧАЛОПЕРИОДА(&ТекущаяДата, ДЕНЬ) КОНЕЦ"");";
	ЗаписатьВидДела(Пользователь, СтолбцыПоУмолчанию, СортировкаПоСроку,,СтрокаОтбор, "Expired",Main,
		НСтр("ru = 'Просрочено'"), 0, 10, Ложь,БиблиотекаКартинок.сстПросрочено);
	
	// ВЕТКА ToDo
	ToDo = ЗаписатьГруппуВидаДела(Пользователь, "ToDo",, НСтр("ru = 'To-Do'"), 11, БиблиотекаКартинок.сстВиды);
	
	СортировкаПоВесу = Новый ТаблицаЗначений;
	СортировкаПоВесу.Колонки.Добавить("Имя");
	СортировкаПоВесу.Колонки.Добавить("Представление");
	СортировкаПоВесу.Колонки.Добавить("Направление");
	ДобавитьСтрокуСортировке(СортировкаПоВесу, НСтр("ru = 'Вес'"),, Перечисления.НаправлениеСортировки.Убывание);
		
	// ActiveAction (Активные действия)
	СтрокаОтборToDo = 
		"МассивУсловий.Добавить(""Дела.Выполнено = Ложь И Дела.ЭтоПапка = Ложь И Дела.СпрятатьВToDo = Ложь И (Дела.ИспользоватьНачало = Ложь ИЛИ (Дела.ИспользоватьНачало = Истина И Дела.Начало > ДатаВремя(1, 1, 1, 0, 0, 0) И Дела.Начало <= &ТекущаяДата))"");";
	ЗаписатьВидДела(Пользователь, СтолбцыПоУмолчанию, СортировкаПоВесу,,СтрокаОтборToDo, "ActiveAction",ToDo, 
		НСтр("ru = 'Активные действия'"), 0, 12, Ложь,БиблиотекаКартинок.сстМеткаКрасная,,,Ложь);
	
	// ActiveActionProject (Активные действия (по проектам))
	ГруппировкаПоПроекту = Новый ТаблицаЗначений;
	ГруппировкаПоПроекту.Колонки.Добавить("Имя");
	ГруппировкаПоПроекту.Колонки.Добавить("Представление");
	ГруппировкаПоПроекту.Колонки.Добавить("Направление");
	ДобавитьСтрокуСортировке(ГруппировкаПоПроекту, НСтр("ru = 'Проект'"));
	
	ЗаписатьВидДела(Пользователь, СтолбцыПоУмолчанию, СортировкаПоВесу, ГруппировкаПоПроекту, СтрокаОтборToDo, 
		"ActiveActionProject", ToDo, НСтр("ru = 'Активные действия (по проектам)'"), 0, 13, Ложь,
		БиблиотекаКартинок.сстМеткаГолубая,,,Ложь);
	
КонецПроцедуры

Функция ТаблицаСтолбцыПоУмолчанию() Экспорт
	
	СтолбцыПоУмолчанию = Новый ТаблицаЗначений;
	СтолбцыПоУмолчанию.Колонки.Добавить("Имя");
	СтолбцыПоУмолчанию.Колонки.Добавить("Представление");		
	ДобавитьСтрокуСтолбцам(СтолбцыПоУмолчанию, "Тема");
	ДобавитьСтрокуСтолбцам(СтолбцыПоУмолчанию, "Контексты");
	ДобавитьСтрокуСтолбцам(СтолбцыПоУмолчанию, "Срок");
	ДобавитьСтрокуСтолбцам(СтолбцыПоУмолчанию, "Напоминание");
	ДобавитьСтрокуСтолбцам(СтолбцыПоУмолчанию, "Отметка");
	ДобавитьСтрокуСтолбцам(СтолбцыПоУмолчанию, "Избранное");
	
	Возврат СтолбцыПоУмолчанию;
		
КонецФункции

#КонецОбласти

#Область Служебные

Процедура ЗаписатьВидДела(Знач Пользователь, 
	Знач СтолбцыПоУмолчанию, Знач СортировкаПоУмолчанию = Неопределено, Знач ГруппировкаПоСроку = Неопределено,
	Знач Отборы = "", Знач Идентификатор, Знач Родитель = Неопределено, 
	Знач Наименование, Знач РежимПросмотраДерева = 0, Знач Порядок, Знач ИерархическийВид = Истина, 
	Знач Картинка = Неопределено, Знач ВключаяРодительскиеДела = Ложь, Знач ВключаяПодчиненныеДела = Ложь,
	Знач ПоказатьСчетчик = Истина)
	
	Запрос = Новый Запрос();
	Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	ВидыДел.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ВидыДел КАК ВидыДел
		|ГДЕ
		|	ВидыДел.Автор = &Пользователь
		|	И ВидыДел.Идентификатор = &Идентификатор
		|	И ВидыДел.ЭтоГруппа = ЛОЖЬ";
	
	Запрос.УстановитьПараметр("Пользователь", Пользователь);
	Запрос.УстановитьПараметр("Идентификатор", Идентификатор);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		НовыйВид 					= Выборка.Ссылка.ПолучитьОбъект();
	Иначе
		НовыйВид 					= Справочники.ВидыДел.СоздатьЭлемент();
	КонецЕсли;

	НовыйВид.Наименование 			= Наименование;
	Если ЗначениеЗаполнено(Родитель) Тогда
		НовыйВид.Родитель			= Родитель;
	КонецЕсли;
	НовыйВид.Идентификатор 			= Идентификатор;
	НовыйВид.РежимПросмотраДерева 	= РежимПросмотраДерева;
	НовыйВид.РеквизитДопУпорядочивания = Порядок;
	НовыйВид.ИерархическийВид		= ИерархическийВид;
	НовыйВид.ВключаяРодительскиеДела= ВключаяРодительскиеДела;
	НовыйВид.ВключаяПодчиненныеДела	= ВключаяПодчиненныеДела;
	НовыйВид.Отборы					= Отборы;
	НовыйВид.Видимость				= Истина;
	НовыйВид.Автор 					= Пользователь;
	НовыйВид.ПоказатьСчетчик		= ПоказатьСчетчик;
	НовыйВид.ПоказыватьСчетчикГруппировки	= Истина;
	НовыйВид.ПоказыватьНазваниеГруппировки	= Истина;
	
	Если Картинка <> Неопределено Тогда
		НовыйВид.Картинка 			= Новый ХранилищеЗначения(Картинка);
	КонецЕсли;
	
	НовыйВид.Столбцы.Очистить();
	Для Каждого Строки Из СтолбцыПоУмолчанию Цикл
		ЗаполнитьЗначенияСвойств(НовыйВид.Столбцы.Добавить(), Строки);
	КонецЦикла;
	
	НовыйВид.Сортировка.Очистить();
	Если СортировкаПоУмолчанию <> Неопределено Тогда
		Для Каждого Строки Из СортировкаПоУмолчанию Цикл
			ЗаполнитьЗначенияСвойств(НовыйВид.Сортировка.Добавить(), Строки);
		КонецЦикла;                                                 
	КонецЕсли;                                                   
	
	НовыйВид.Группировки.Очистить();
	Если ГруппировкаПоСроку <> Неопределено Тогда
		Для Каждого Строки Из ГруппировкаПоСроку Цикл
			ЗаполнитьЗначенияСвойств(НовыйВид.Группировки.Добавить(), Строки);
		КонецЦикла;		
	КонецЕсли;
	
	НовыйВид.Записать();
	
КонецПроцедуры

Функция ЗаписатьГруппуВидаДела(Знач Пользователь, Знач Идентификатор, Знач Родитель = Неопределено, Знач Наименование,
	Знач Порядок, Знач Картинка = Неопределено)
	
	ВидДелаСсылка = УправлениеДелами.НайтиВидДелаПоИдентификатору(Идентификатор, Пользователь);
	
	Если ЗначениеЗаполнено(ВидДелаСсылка) Тогда
		НовыйВид 					= ВидДелаСсылка.ПолучитьОбъект();		
	Иначе
		НовыйВид 					= Справочники.ВидыДел.СоздатьГруппу();
	КонецЕсли;
	
	НовыйВид.Наименование 			= Наименование;
	Если ЗначениеЗаполнено(Родитель) Тогда
		НовыйВид.Родитель			= Родитель;
	КонецЕсли;
	НовыйВид.Идентификатор 			= Идентификатор;
	НовыйВид.Автор		 			= Пользователь;
	НовыйВид.РеквизитДопУпорядочивания = Порядок;
	НовыйВид.Видимость				= Истина;
	Если Картинка <> Неопределено Тогда
		НовыйВид.Картинка 			= Новый ХранилищеЗначения(Картинка);
	КонецЕсли;
	
	НовыйВид.Записать();
	
	Возврат НовыйВид.Ссылка;
	
КонецФункции

Процедура ДобавитьСтрокуСтолбцам(Таблица, Знач Имя, Знач Представление = Неопределено)
	
	НоваяСтрока 				= Таблица.Добавить();
	НоваяСтрока.Имя 			= Имя;
	НоваяСтрока.Представление 	= ?(Представление = Неопределено, Имя, Представление);
	
КонецПроцедуры

Процедура ДобавитьСтрокуСортировке(Таблица, Знач Имя, Знач Представление = Неопределено,
	Знач Направление = Неопределено)
	
	НоваяСтрока 				= Таблица.Добавить();
	НоваяСтрока.Имя 			= Имя;
	НоваяСтрока.Представление 	= ?(Представление = Неопределено, Имя, Представление);
	НоваяСтрока.Направление 	= ?(Направление = Неопределено, Перечисления.НаправлениеСортировки.Возрастание, Направление);
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли