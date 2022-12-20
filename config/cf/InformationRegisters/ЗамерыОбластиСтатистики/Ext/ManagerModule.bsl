﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

Процедура ЗаписатьЗамеры(Замеры) Экспорт
	Если ТипЗнч(Замеры) = Тип("РезультатЗапроса") Тогда
		ЗаписатьРезультатЗапроса(Замеры);
	КонецЕсли;
КонецПроцедуры

Процедура ЗаписатьРезультатЗапроса(Замеры)
	Если НЕ Замеры.Пустой() Тогда
		НаборЗаписей = СоздатьНаборЗаписей();
		
		Выборка = Замеры.Выбрать();
		Пока Выборка.Следующий() Цикл
			НовЗапись = НаборЗаписей.Добавить();
			НовЗапись.Период = Выборка.Период;
			НовЗапись.ОперацияСтатистики = Выборка.ОперацияСтатистики;
			НовЗапись.ОбластьСтатистики = Выборка.ОбластьСтатистики;
			НовЗапись.ИдентификаторУдаления = Выборка.ИдентификаторУдаления;
			НовЗапись.КоличествоЗначений = Выборка.КоличествоЗначений;
			НовЗапись.ПериодОкончание = Выборка.ПериодОкончание;
		КонецЦикла;
		
		НаборЗаписей.ОбменДанными.Загрузка = Истина;
		НаборЗаписей.Записать(Ложь);
	КонецЕсли;
КонецПроцедуры

Функция ПолучитьАгрегированныеЗаписи(ГраницаАгрегирования, ОбработатьЗаписиДо, ПериодАгрегации, ПериодУдаления) Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((РАЗНОСТЬДАТ(ДАТАВРЕМЯ(2015,1,1), ЗамерыОбластиСтатистики.Период, СЕКУНДА) + 63555667200)/&ПериодАгрегации - 0.5 КАК ЧИСЛО(11,0)) * &ПериодАгрегации - 63555667200) КАК Период,
	|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((РАЗНОСТЬДАТ(ДАТАВРЕМЯ(2015,1,1), ЗамерыОбластиСтатистики.Период, СЕКУНДА) + 63555667200)/&ПериодАгрегации - 0.5 КАК ЧИСЛО(11,0)) * &ПериодАгрегации - 63555667200 + &ПериодАгрегации - 1) КАК ПериодОкончание,
	|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((РАЗНОСТЬДАТ(ДАТАВРЕМЯ(2015,1,1), ЗамерыОбластиСтатистики.Период, СЕКУНДА) + 63555667200)/&ПериодУдаления - 0.5 КАК ЧИСЛО(11,0)) * &ПериодУдаления - 63555667200) КАК ИдентификаторУдаления,
	|	ЗамерыОбластиСтатистики.ОперацияСтатистики,
	|	ЗамерыОбластиСтатистики.ОбластьСтатистики,
	|	СУММА(ЗамерыОбластиСтатистики.КоличествоЗначений) КАК КоличествоЗначений
	|ИЗ
	|	РегистрСведений.ЗамерыОбластиСтатистики КАК ЗамерыОбластиСтатистики
	|ГДЕ
	|	ЗамерыОбластиСтатистики.Период >= &ГраницаАгрегирования
	|	И ЗамерыОбластиСтатистики.Период < &ОбработатьЗаписиДо
	|СГРУППИРОВАТЬ ПО
	|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((РАЗНОСТЬДАТ(ДАТАВРЕМЯ(2015,1,1), ЗамерыОбластиСтатистики.Период, СЕКУНДА) + 63555667200)/&ПериодАгрегации - 0.5 КАК ЧИСЛО(11,0)) * &ПериодАгрегации - 63555667200),
	|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((РАЗНОСТЬДАТ(ДАТАВРЕМЯ(2015,1,1), ЗамерыОбластиСтатистики.Период, СЕКУНДА) + 63555667200)/&ПериодАгрегации - 0.5 КАК ЧИСЛО(11,0)) * &ПериодАгрегации - 63555667200 + &ПериодАгрегации - 1),
	|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((РАЗНОСТЬДАТ(ДАТАВРЕМЯ(2015,1,1), ЗамерыОбластиСтатистики.Период, СЕКУНДА) + 63555667200)/&ПериодУдаления - 0.5 КАК ЧИСЛО(11,0)) * &ПериодУдаления - 63555667200),
	|	ЗамерыОбластиСтатистики.ОперацияСтатистики,
	|	ЗамерыОбластиСтатистики.ОбластьСтатистики
	|";
	
	Запрос.УстановитьПараметр("ГраницаАгрегирования", ГраницаАгрегирования);
	Запрос.УстановитьПараметр("ОбработатьЗаписиДо", ОбработатьЗаписиДо);
	Запрос.УстановитьПараметр("ПериодАгрегации", ПериодАгрегации);
	Запрос.УстановитьПараметр("ПериодУдаления", ПериодУдаления);
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат РезультатЗапроса;
КонецФункции

Процедура УдалитьЗаписи(ГраницаАгрегирования, ОбработатьЗаписиДо) Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ЗамерыОбластиСтатистики.ИдентификаторУдаления	
	|ИЗ
	|	РегистрСведений.ЗамерыОбластиСтатистики КАК ЗамерыОбластиСтатистики
	|ГДЕ
	|	ЗамерыОбластиСтатистики.Период >= &ГраницаАгрегирования
	|	И ЗамерыОбластиСтатистики.Период < &ОбработатьЗаписиДо
	|";
	
	Запрос.УстановитьПараметр("ГраницаАгрегирования", ГраницаАгрегирования);
	Запрос.УстановитьПараметр("ОбработатьЗаписиДо", ОбработатьЗаписиДо);
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	
	НаборЗаписей = СоздатьНаборЗаписей();
	Пока Выборка.Следующий() Цикл
		
		НаборЗаписей.Отбор.ИдентификаторУдаления.Установить(Выборка.ИдентификаторУдаления);
		НаборЗаписей.Записать(Истина);
	КонецЦикла;
КонецПроцедуры

Функция ПолучитьЗамеры(ДатаНачала, ДатаОкончания, ПериодУдаления) Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	ОперацииСтатистики.Наименование КАК ОперацияСтатистики,
	|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((РАЗНОСТЬДАТ(ДАТАВРЕМЯ(2015,1,1), ЗамерыОбластиСтатистики.Период, СЕКУНДА) + 63555667200)/&ПериодУдаления - 0.5 КАК ЧИСЛО(11,0)) * &ПериодУдаления - 63555667200) КАК Период,
	|	ОбластиСтатистики.Наименование КАК ОбластьСтатистики,
	|	СУММА(ЗамерыОбластиСтатистики.КоличествоЗначений) КАК КоличествоЗначений
	|ИЗ
	|	РегистрСведений.ЗамерыОбластиСтатистики КАК ЗамерыОбластиСтатистики
	|ВНУТРЕННЕЕ СОЕДИНЕНИЕ
	|	РегистрСведений.ОперацииСтатистики КАК ОперацииСтатистики
	|ПО
	|	ЗамерыОбластиСтатистики.ОперацияСтатистики = ОперацииСтатистики.ИдентификаторОперации
	|ВНУТРЕННЕЕ СОЕДИНЕНИЕ
	|	РегистрСведений.ОбластиСтатистики КАК ОбластиСтатистики
	|ПО
	|	ЗамерыОбластиСтатистики.ОбластьСтатистики = ОбластиСтатистики.ИдентификаторОбласти
	|ГДЕ
	|	ЗамерыОбластиСтатистики.Период >= &ДатаНачала
	|	И ЗамерыОбластиСтатистики.ПериодОкончание <= &ДатаОкончания
	|	И ЗамерыОбластиСтатистики.ИдентификаторУдаления < ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((РАЗНОСТЬДАТ(ДАТАВРЕМЯ(2015,1,1), &ДатаОкончания, СЕКУНДА) + 63555667200)/&ПериодУдаления - 0.5 КАК ЧИСЛО(11,0)) * &ПериодУдаления - 63555667200)
	|СГРУППИРОВАТЬ ПО
	|	ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((РАЗНОСТЬДАТ(ДАТАВРЕМЯ(2015,1,1), ЗамерыОбластиСтатистики.Период, СЕКУНДА) + 63555667200)/&ПериодУдаления - 0.5 КАК ЧИСЛО(11,0)) * &ПериодУдаления - 63555667200),
	|	ОперацииСтатистики.Наименование,
	|	ОбластиСтатистики.Наименование
	|УПОРЯДОЧИТЬ ПО
	|   ДОБАВИТЬКДАТЕ(ДАТАВРЕМЯ(2015,1,1),СЕКУНДА, ВЫРАЗИТЬ((РАЗНОСТЬДАТ(ДАТАВРЕМЯ(2015,1,1), ЗамерыОбластиСтатистики.Период, СЕКУНДА) + 63555667200)/&ПериодУдаления - 0.5 КАК ЧИСЛО(11,0)) * &ПериодУдаления - 63555667200),
	|	ОперацииСтатистики.Наименование,
	|	ОбластиСтатистики.Наименование
	|";
	
	Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", ДатаОкончания);
	Запрос.УстановитьПараметр("ПериодУдаления", ПериодУдаления);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат РезультатЗапроса;	
КонецФункции

#КонецОбласти

#КонецЕсли