﻿
// <Описание процедуры>
//
// Параметры:
//  <Параметр1>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//  <Параметр2>  - <Тип.Вид> - <описание параметра>
//                 <продолжение описания параметра>
//
Процедура ДвиженияРС_Работы(Отказ)

	
	//SM 07072022
	//Движение по регистру оплат
	Движения.РС_Работы.Очистить();
	Движения.РС_Работы.Записывать = Истина;
	
	ТекстЗапроса =  "ВЫБРАТЬ
	|	Занятости.Занятость КАК Занятость,
	|	Занятости.Часы КАК Часы,
	|	Занятости.Занятость.Исполнитель.Подразделение КАК НачисленоСотруднику,
	|	&ВидДвижения КАК ВидДвижения,
	|	&Период КАК Период
	|ИЗ
	|	&Занятости КАК Занятости";
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Занятости", Работы.Выгрузить());
	Запрос.УстановитьПараметр("Период", КонецДня(Дата));
	Запрос.УстановитьПараметр("ВидДвиженияПриход", ВидДвиженияНакопления.Расход);
	Движения.РС_Работы.Загрузить(Запрос.Выполнить().Выгрузить());
	Движения.РС_Работы.Записать();
	
	//----- 	

КонецПроцедуры // ДвижениеРС_Оплаты()


Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	ДвиженияРС_Работы(Отказ);
КонецПроцедуры
