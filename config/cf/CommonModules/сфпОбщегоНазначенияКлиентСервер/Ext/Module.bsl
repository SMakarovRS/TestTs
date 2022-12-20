﻿////////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС

// Формирует и выводит сообщение, которое может быть связано с элементом 
// управления формы.
//
//  Параметры
//  ТекстСообщенияПользователю - Строка - текст сообщения.
//  КлючДанных                 - ЛюбаяСсылка - на объект информационной базы.
//                               Ссылка на объект информационной базы, к которому это сообщение относится,
//                               или ключ записи.
//  Поле                       - Строка - наименование реквизита формы.
//  ПутьКДанным                - Строка - путь к данным (путь к реквизиту формы).
//  Отказ                      - Булево - Выходной параметр.
//                               Всегда устанавливается в значение Истина.
//
//	Пример:
//
//	1. Для вывода сообщения у поля управляемой формы, связанного с реквизитом объекта:
//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
//		НСтр("ru = 'Сообщение об ошибке.'"), ,
//		"ПолеВРеквизитеФормыОбъект",
//		"Объект");
//
//	Альтернативный вариант использования в форме объекта:
//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
//		НСтр("ru = 'Сообщение об ошибке.'"), ,
//		"Объект.ПолеВРеквизитеФормыОбъект");
//
//	2. Для вывода сообщения рядом с полем управляемой формы, связанным с реквизитом формы:
//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
//		НСтр("ru = 'Сообщение об ошибке.'"), ,
//		"ИмяРеквизитаФормы");
//
//	3. Для вывода сообщения связанного с объектом информационной базы.
//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
//		НСтр("ru = 'Сообщение об ошибке.'"), ОбъектИнформационнойБазы, "Ответственный",,Отказ);
//
// 4. Для вывода сообщения по ссылке на объект информационной базы.
//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
//		НСтр("ru = 'Сообщение об ошибке.'"), Ссылка, , , Отказ);
//
// Случаи некорректного использования:
//  1. Передача одновременно параметров КлючДанных и ПутьКДанным.
//  2. Передача в параметре КлючДанных значения типа отличного от допустимых.
//  3. Установка ссылки без установки поля (и/или пути к данным).
//
Процедура сфпСообщитьПользователю(
		Знач ТекстСообщенияПользователю,
		Знач КлючДанных = Неопределено,
		Знач Поле = "",
		Знач ПутьКДанным = "",
		Отказ = Ложь) Экспорт
	
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = ТекстСообщенияПользователю;
	Сообщение.Поле = Поле;
	
	ЭтоОбъект = Ложь;
	
#Если НЕ ТонкийКлиент И НЕ ВебКлиент Тогда
	Если КлючДанных <> Неопределено
	   И XMLТипЗнч(КлючДанных) <> Неопределено Тогда
		ТипЗначенияСтрокой = XMLТипЗнч(КлючДанных).ИмяТипа;
		ЭтоОбъект = Найти(ТипЗначенияСтрокой, "Object.") > 0;
	КонецЕсли;
#КонецЕсли
	
	Если ЭтоОбъект Тогда
		Сообщение.УстановитьДанные(КлючДанных);
	Иначе
		Сообщение.КлючДанных = КлючДанных;
	КонецЕсли;
	
	Если НЕ ПустаяСтрока(ПутьКДанным) Тогда
		Сообщение.ПутьКДанным = ПутьКДанным;
	КонецЕсли;
		
	Сообщение.Сообщить();
	
	Отказ = Истина;
	
КонецПроцедуры

// Возвращает текущего пользователя или текущего внешнего пользователя,
// в зависимости от того, кто выполнил вход в сеанс.
//  Рекомендуется использовать в коде, который поддерживает работу в обоих случаях.
//
// Возвращаемое значение:
//  СправочникСсылка.Пользователи, СправочникСсылка.ВнешниеПользователи - пользователь
//    или внешний пользователь.
//
Функция сфпАвторизованныйПользователь() Экспорт
	
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
	УстановитьПривилегированныйРежим(Истина);
	
	Попытка
		ТекПользователь = ПараметрыСеанса["ТекущийПользователь"];
	Исключение
		Возврат Справочники.Пользователи.ПустаяСсылка();
	КонецПопытки;
	
	Если ЗначениеЗаполнено(ТекПользователь) Тогда
		Возврат ТекПользователь;
	Иначе
		Возврат Справочники.Пользователи.ПустаяСсылка();
	КонецЕсли;
	
#Иначе
	Возврат ПредопределенноеЗначение("Справочник.Пользователи.ПустаяСсылка");
#КонецЕсли
	
КонецФункции

// Разбивает строку на несколько строк по разделителю. Разделитель может иметь любую длину.
//
// Параметры:
//  Строка                 - Строка - текст с разделителями;
//  Разделитель            - Строка - разделитель строк текста, минимум 1 символ;
//  ПропускатьПустыеСтроки - Булево - признак необходимости включения в результат пустых строк.
//    Если параметр не задан, то функция работает в режиме совместимости со своей предыдущей версией:
//     - для разделителя-пробела пустые строки не включаются в результат, для остальных разделителей пустые строки
//       включаются в результат.
//     - если параметр Строка не содержит значащих символов или не содержит ни одного символа (пустая строка), то в
//       случае разделителя-пробела результатом функции будет массив, содержащий одно значение "" (пустая строка), а
//       при других разделителях результатом функции будет пустой массив.
//
//
// Возвращаемое значение:
//  Массив - массив строк.
//
// Примеры:
//  РазложитьСтрокуВМассивПодстрок(",один,,два,", ",") - возвратит массив из 5 элементов, три из которых  - пустые строки;
//  РазложитьСтрокуВМассивПодстрок(",один,,два,", ",", Истина) - возвратит массив из двух элементов;
//  РазложитьСтрокуВМассивПодстрок(" один   два  ", " ") - возвратит массив из двух элементов;
//  РазложитьСтрокуВМассивПодстрок("") - возвратит пустой массив;
//  РазложитьСтрокуВМассивПодстрок("",,Ложь) - возвратит массив с одним элементом "" (пустой строкой);
//  РазложитьСтрокуВМассивПодстрок("", " ") - возвратит массив с одним элементом "" (пустой строкой);
//
Функция сфпРазложитьСтрокуВМассивПодстрок(Знач Строка, Знач Разделитель = ",", Знач ПропускатьПустыеСтроки = Неопределено) Экспорт
	
	Результат = Новый Массив;
	
	// для обеспечения обратной совместимости
	Если ПропускатьПустыеСтроки = Неопределено Тогда
		ПропускатьПустыеСтроки = ?(Разделитель = " ", Истина, Ложь);
		Если ПустаяСтрока(Строка) Тогда 
			Если Разделитель = " " Тогда
				Результат.Добавить("");
			КонецЕсли;
			Возврат Результат;
		КонецЕсли;
	КонецЕсли;
	//
	
	Позиция = Найти(Строка, Разделитель);
	Пока Позиция > 0 Цикл
		Подстрока = Лев(Строка, Позиция - 1);
		Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Подстрока) Тогда
			Результат.Добавить(Подстрока);
		КонецЕсли;
		Строка = Сред(Строка, Позиция + СтрДлина(Разделитель));
		Позиция = Найти(Строка, Разделитель);
	КонецЦикла;
	
	Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Строка) Тогда
		Результат.Добавить(Строка);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции 

// Формирует строковое представление телефона.
//
// Параметры:
//    КодСтраны     - Строка - код страны.
//    КодГорода     - Строка - код города.
//    НомерТелефона - Строка - номер телефона.
//    Добавочный    - Строка - добавочный номер.
//    Комментарий   - Строка - комментарий.
//
// Возвращаемое значение - Строка - представление телефона.
//
Функция сфпСформироватьПредставлениеТелефона(КодСтраны, КодГорода, НомерТелефона, Добавочный, Комментарий) Экспорт
	
	Представление = СокрЛП(КодСтраны);
	Если Не ПустаяСтрока(Представление) И Лев(Представление,1)<>"+" Тогда
		Представление = "+" + Представление;
	КонецЕсли;
	
	Если Не ПустаяСтрока(КодГорода) Тогда
		Представление = Представление + ?(ПустаяСтрока(Представление), "", " ") + "(" + СокрЛП(КодГорода) + ")";
	КонецЕсли;
	
	Если Не ПустаяСтрока(НомерТелефона) Тогда
		Представление = Представление + ?(ПустаяСтрока(Представление), "", " ") + СокрЛП(НомерТелефона);
	КонецЕсли;
	
	Если НЕ ПустаяСтрока(Добавочный) Тогда
		Представление = Представление + ?(ПустаяСтрока(Представление), "", ", ") + "доб. " + СокрЛП(Добавочный);
	КонецЕсли;
	
	Если НЕ ПустаяСтрока(Комментарий) Тогда
		Представление = Представление + ?(ПустаяСтрока(Представление), "", ", ") + СокрЛП(Комментарий);
	КонецЕсли;
	
	Возврат Представление;
	
КонецФункции

// Процедера использует пустой обработчик оповещения для случая, 
// когда обработчик обязателен, но фактически он ничего делать не должен
//
Процедура сфпОбработчикОповещенияБезДействия(Результат, ДополнительныеПараметры) Экспорт
	Возврат;
КонецПроцедуры
