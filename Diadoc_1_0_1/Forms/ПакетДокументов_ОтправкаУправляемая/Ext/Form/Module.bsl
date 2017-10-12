﻿&НаСервере
Перем ОбработкаОбъект;

&Наклиенте
Перем ОсновнаяФорма;

//{		Сервисные методы
	
&НаСервере
Функция ОбработкаОбъект()

	Если ОбработкаОбъект=Неопределено Тогда
		ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	КонецЕсли;	
	
	Возврат ОбработкаОбъект;
	
КонецФункции

&НаКлиенте
Функция ОсновнаяФорма() Экспорт

	Если ОсновнаяФорма=Неопределено Тогда
		ОсновнаяФорма = ВладелецФормы.ОсновнаяФорма();
	КонецЕсли;	
	
	Возврат ОсновнаяФорма;
	
КонецФункции

//}		Сервисные методы

&НаКлиенте
Процедура ПодписатьИОтправить(Команда)
	
	Для Каждого ОписаниеДокумента Из Пакет.Документы Цикл
		Если НЕ ЗначениеЗаполнено(ОписаниеДокумента.Документ1С) И ОписаниеДокумента.Тип = "Nonformalized" Тогда
			ОписаниеДокумента.Content.Вставить("NeedRecipientSignature", ЗапрашиватьОтветнуюПодписьДобавленныхВПакетФайлов);
		КонецЕсли;
	КонецЦикла;
	
	ОписаниеОповещения = ОсновнаяФорма().НовыйОписаниеОповещения("ЭДО_ПакетДокументов_Отправить",ОсновнаяФорма(),Пакет);
	ОсновнаяФорма().ВыполнитьДействиеПослеАвторизации(ОписаниеОповещения);
	
	// закрытие формы вынесено в ОбработкаОповещения
	
	// Можно прокинуть сюда параметром данную форму
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("СтрокаИзИнтерфейса") Тогда
		Пакет = ОбработкаОбъект().СобратьПакетПоСтрокеСписка(Параметры.СтрокаИзИнтерфейса);
	КонецЕсли;
	
	Для Каждого Эл Из Пакет.Документы Цикл
		НоваяСтрока = СписокДокументовПакета.Добавить();
	    ЗаполнитьЗначенияСвойств(НоваяСтрока,Эл);
	КонецЦикла;
	
	СоответствияДляМаршрутизации = ОбработкаОбъект().СсылкиНаСоответствияДляМаршрутизации(Пакет);
	ЗаполнитьЗначенияСвойств(ЭтаФорма,СоответствияДляМаршрутизации);
	ПоказатьОписаниеОшибки();
	
	Если НЕ ЗначениеЗаполнено(Пакет.Данные1С.ПереотправляемыйПакетСсылка) Тогда
		Элементы.ФормаПереотправить.Видимость = Ложь;
	Иначе
		Элементы.ФормаПодписатьИОтправить.Видимость = Ложь;
	КонецЕсли;
	
	// уберем кнопки создания в 8.3.8
	Попытка
		Выполнить("
		|Элементы.ПодразделениеОтправителя.КнопкаСоздания = Ложь;
		|Элементы.ПодразделениеПолучателя.КнопкаСоздания = Ложь;
		|");
	Исключение
	КонецПопытки;
	
КонецПроцедуры

// Отображает/скрывает правую панель с описанием ошибки, возникшей при предыдущей отправке пакета
&НаСервере
Процедура ПоказатьОписаниеОшибки()
	
	Если ЗначениеЗаполнено(Пакет.Данные1С.ПереотправляемыйПакетСсылка) Тогда
		ОписаниеОшибки = ОбработкаОбъект().ЭДО_ПолучитьОписаниеОшибкиПереотправляемогоПакета(Пакет.Данные1С.ПереотправляемыйПакетСсылка);
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ОписаниеОшибки) Тогда
		
		Элементы.ОписаниеОшибки.Видимость = Ложь;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокДокументовПакетаВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	
	ДокументЭДО	= Пакет.Документы[СписокДокументовПакета.Индекс(Элементы.СписокДокументовПакета.ТекущиеДанные)];	
	
	Если ЭтоФормализованныйДокументНаСервере(ДокументЭДО.Тип) Тогда
	
		мИмяФормы = "КарточкаДокументаУправляемая";
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("ДокументЭДО", ДокументЭДО);//тоже не совсем правильно
		
		ФормаЭлемента = ОсновнаяФорма().ПолучитьФормуОбработки(мИмяФормы,ПараметрыФормы);
		ФормаЭлемента.Открыть();
		
	Иначе
		
		Если ТипЗнч(ДокументЭДО.ДвоичныеДанные) = Тип("ТабличныйДокумент") Тогда
			
			ДокументЭДО.ДвоичныеДанные.Показать();
			
		Иначе
			
			ИмяВремФайла = КаталогВременныхФайлов()+ДокументЭДО.ИмяФайла;			
			ДокументЭДО.ДвоичныеДанные.Записать(ИмяВремФайла);			
			ЗапуститьПриложение(ИмяВремФайла);
			
		КонецЕсли;
		
	КонецЕсли;
		
КонецПроцедуры

&НаСервере
Функция ЭтоФормализованныйДокументНаСервере(ТипДокументаЭДО)
	
	Возврат ОбработкаОбъект().ЭДО_ПредопределенныеСписки_Получить("ТипыДокументов").Найти(ТипДокументаЭДО,"Наименование").Формализованный;
	
КонецФункции

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия="Диадок_ПакетДокументов_Отправка" Тогда

		Если Пакет.Данные1С.ВидПакета = Параметр.Данные1С.ВидПакета
			И Пакет.Данные1С.Документ = Параметр.Данные1С.Документ Тогда
			
			//ОсновнаяФорма().Модуль_Платформа().ПоказатьПредупреждениеПереопределенная(,"Пакет успешно отправлен");  //может быть отправлен и не успешно - необходима проверка на это
			//Оповестить("Диадок_ОбновитьГлавныйСписок");
			Закрыть("Диадок_ОбновитьГлавныйСписок");
			
		КонецЕсли;
	
	ИначеЕсли ИмяСобытия = "Диадок_ПакетДокументов_Отправка_ЗагрузкаПодразделений" Тогда
				
		СформироватьДеревоПодразделенийНаСервере_1СЭДО(Параметр);
					
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытиеЭлементаМаршрутизации(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Если НЕ ЗначениеЗаполнено(ЭтаФорма[Элемент.Имя]) Тогда
		Возврат;
	КонецЕсли;
	
	Если Элемент.Имя = "Отправитель" Тогда
		
		мИмяСправочника	= "Организации";
		мИмяФормы		= "Организации";
		
	ИначеЕсли Элемент.Имя = "Получатель" Тогда
		
		мИмяСправочника	= "Контрагенты";
		мИмяФормы		= "Контрагенты";
		
	ИначеЕсли Элемент.Имя = "ПодразделениеОтправителя" Тогда
		
		мИмяСправочника	= "ПодразделенияОрганизаций";
		мИмяФормы		= "Организации";
		
	ИначеЕсли Элемент.Имя = "ПодразделениеПолучателя" Тогда
		
		мИмяСправочника	= "ПодразделенияКонтрагентов";
		мИмяФормы		= "Контрагенты";
		
	КонецЕсли;
	
	ПараметрыФормы=	Новый Структура;
	ПараметрыФормы.Вставить("Ссылка",							ЭтаФорма[Элемент.Имя]);
	ПараметрыФормы.Вставить("Новая",							Ложь);
	ПараметрыФормы.Вставить("ИмяСправочника",					мИмяСправочника);
	ПараметрыФормы.Вставить("ЗакрыватьПриЗакрытииВладельца",	Истина);
	
	ОткрытьФорму(ОсновнаяФорма().Модуль_Платформа().ПутьКФормам+мИмяФормы+"_ФормаЭлементаУправляемая", ПараметрыФормы, ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьПроизвольныйФайл(Команда)
	
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Заголовок = "Выберите файл";
	Диалог.ПолноеИмяФайла = ""; 
	Фильтр = НСтр("ru = 'Все файлы(*.*)|*.*'");
	Диалог.Фильтр = Фильтр; 
    Диалог.МножественныйВыбор = Истина;
	
	масБольшиеФайлы = Новый Массив;
	Если Диалог.Выбрать() Тогда
		Для Каждого ЭлементМассива Из Диалог.ВыбранныеФайлы Цикл
			
			ФайлДанных = Новый Файл(ЭлементМассива);
			
			Если ФайлДанных.Размер() > (5*1024*1024) Тогда
				масБольшиеФайлы.Добавить(ФайлДанных);
				Продолжить;
			КонецЕсли;

			ТекДанные = СписокДокументовПакета.Добавить();
			ТекДанные.Заголовок =  ФайлДанных.Имя;
			ТекДанные.Тип = "Nonformalized";
			
			СтруктураДанных = ПолучитьРеквизитыДокументаСтрокойНаСервере();
			СтруктураДанных.Заголовок = ФайлДанных.Имя;
			СтруктураДанных.ИмяФайла = ФайлДанных.Имя;
			СтруктураДанных.Тип = "Nonformalized";
			СтруктураДанных.Вид = ""; //возможно д.б. ссылка на некий вид документа "Файл" - Nonformilized
			СтруктураДанных.ДвоичныеДанные = Новый ДвоичныеДанные(ФайлДанных.ПолноеИмя);
			СтруктураДанных.Content = Новый Структура;
			
			Пакет.Документы.Добавить(СтруктураДанных);			
			
		КонецЦикла;
	КонецЕсли;
	
	Если масБольшиеФайлы.Количество() > 0 Тогда
		
		стрПредупреждения = "Размер отправляемого файла не должен превышать 5 Мб.
							|Невозможно добавить следующие файлы:";
		Для каждого большойФайл Из масБольшиеФайлы Цикл
			стрПредупреждения = стрПредупреждения + "
								|- " + большойФайл.Имя;
		КонецЦикла;		
		
		ОсновнаяФорма().Модуль_Платформа().ПоказатьПредупреждениеПереопределенная(,стрПредупреждения);
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьРеквизитыДокументаСтрокойНаСервере()
	
	Возврат Новый Структура(ОбработкаОбъект().ЭДО_ДокументМенеджер_РеквизитыДокументаСтрокой());
	
КонецФункции

&НаКлиенте
Процедура УдалитьФайл(Команда)
	
	ТекДанные = Элементы.СписокДокументовПакета.ТекущиеДанные;
		
	Пакет.Документы.Удалить(СписокДокументовПакета.Индекс(ТекДанные));
	СписокДокументовПакета.Удалить(ТекДанные);
		
КонецПроцедуры

&НаКлиенте
Процедура ПодразделениеПолучателяНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	НачатьВыборПодразделения("Получатель");
	
КонецПроцедуры

&НаКлиенте
Процедура ПодразделениеОтправителяНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	НачатьВыборПодразделения("Отправитель");
	
КонецПроцедуры

&НаКлиенте
Процедура НачатьВыборПодразделения(Вид)
	
	ПараметрыФормы=	Новый Структура;
	ПараметрыФормы.Вставить("ЮрФизЛицо",						?(Вид = "Получатель", Получатель, Отправитель));
	ПараметрыФормы.Вставить("ЗакрыватьПриЗакрытииВладельца",	Истина);
	
	Если ОсновнаяФорма().Параметры.Использовать1СЭДО Тогда
		Если Вид = "Отправитель" Тогда
			ПараметрыФормы.Вставить("Ссылка", Пакет.Данные1С.ПрофильНастроекЭДО);
		ИначеЕсли Вид = "Получатель" Тогда
			ПараметрыФормы.Вставить("Ссылка", Пакет.Данные1С.СоглашениеОбИспользованииЭДО);
		КонецЕсли;
	КонецЕсли;
		
	ПолноеИмяФормы = ОсновнаяФорма().Модуль_Платформа().ПутьКФормам + "Подразделения_ФормаСпискаУправляемая";
	
	Если ОсновнаяФорма().Параметры.МодальностьЗапрещена Тогда
		ОписаниеОповещения = ОсновнаяФорма().НовыйОписаниеОповещения("ОбработкаВыбораПодразделенияПолучателя",ЭтаФорма, Вид);
		Выполнить("ОткрытьФорму(ПолноеИмяФормы, ПараметрыФормы, ЭтаФорма,,,,ОписаниеОповещения)");
	Иначе	
		РезультатОткрытия = ОткрытьФормуМодально(ПолноеИмяФормы, ПараметрыФормы, ЭтаФорма);
		ОбработкаВыбораПодразделенияПолучателя(РезультатОткрытия, Вид);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбораПодразделенияПолучателя(РезультатЗакрытия=Неопределено,Вид=Неопределено) Экспорт
	
	Если РезультатЗакрытия<>Неопределено Тогда
		
		Если ОсновнаяФорма().Параметры.Использовать1СЭДО Тогда
			
			Если Вид = "Отправитель" Тогда
				
				ПодразделениеОтправителя = РезультатЗакрытия.Наименование;
				Пакет.Данные1С.ПодразделениеОрганизации = РезультатЗакрытия.Наименование;			
				Пакет.ДанныеДД.FromDepartmentId = РезультатЗакрытия.Id;
				
			ИначеЕсли Вид = "Получатель" Тогда	
				
				ПодразделениеПолучателя = РезультатЗакрытия.Наименование;
				Пакет.Данные1С.ПодразделениеКонтрагента = РезультатЗакрытия.Наименование;
				Пакет.ДанныеДД.ToDepartmentId = РезультатЗакрытия.Id;
				
			КонецЕсли;
			
		Иначе
			
			Если Вид = "Отправитель" Тогда
				
				ПодразделениеОтправителя = РезультатЗакрытия.Ссылка;
				Пакет.Данные1С.ПодразделениеОрганизации = РезультатЗакрытия.Ссылка;			
				Пакет.ДанныеДД.FromDepartmentId = РезультатЗакрытия.ID;
				
			ИначеЕсли Вид = "Получатель" Тогда	
				
				ПодразделениеПолучателя = РезультатЗакрытия.Ссылка;
				Пакет.Данные1С.ПодразделениеКонтрагента = РезультатЗакрытия.Ссылка;
				Пакет.ДанныеДД.ToDepartmentId = РезультатЗакрытия.ID;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПодразделениеПолучателяПриИзменении(Элемент)
	
	УстановитьПодразделениеНаСервере("Получатель", ПодразделениеПолучателя);
	
	Если Пакет.ДанныеДД.ToDepartmentId = Неопределено Тогда
		Если ОсновнаяФорма().Параметры.Использовать1СЭДО Тогда
			ПодразделениеПолучателя = "";
		Иначе
			ПодразделениеПолучателя = ПредопределенноеЗначение("Справочник.Диадок_ДополнительныеСправочники.ПустаяСсылка");
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПодразделениеОтправителяПриИзменении(Элемент)
	
	УстановитьПодразделениеНаСервере("Отправитель", ПодразделениеОтправителя);
	
	Если Пакет.ДанныеДД.FromDepartmentId = Неопределено Тогда
		Если ОсновнаяФорма().Параметры.Использовать1СЭДО Тогда
			ПодразделениеОтправителя = "";
		Иначе
			ПодразделениеОтправителя = ПредопределенноеЗначение("Справочник.Диадок_ДополнительныеСправочники.ПустаяСсылка");
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьПодразделениеНаСервере(Вид, Подразделение)
	
	Если ОбработкаОбъект().ЭДО_Использовать1СЭДО() Тогда
		
		Если ТипЗнч(Подразделение) = Тип("Строка") Тогда //пользователь строкой прописал наименование нужного подразделения - попробуем его найти							
			
			Если Вид = "Получатель" Тогда
				мДеревоПодразделений = РеквизитФормыВЗначение("ДеревоПодразделенийПолучателя");
			ИначеЕсли Вид = "Отправитель" Тогда
				мДеревоПодразделений = РеквизитФормыВЗначение("ДеревоПодразделенийОтправителя");
			КонецЕсли;
			
			ДанныеПодразделения = мДеревоПодразделений.Строки.Найти(Подразделение, "Наименование", Истина);
			
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ДанныеПодразделения) Тогда
			ДанныеПодразделения = Новый Структура("Наименование,Id", "");
		КонецЕсли;
		
		Подразделение = ДанныеПодразделения.Наименование;
		
		Если Вид = "Получатель" Тогда			
			Пакет.Данные1С.ПодразделениеКонтрагента = ДанныеПодразделения.Наименование;
			Пакет.ДанныеДД.ToDepartmentId = ДанныеПодразделения.Id;
		ИначеЕсли Вид = "Отправитель" Тогда			
			Пакет.Данные1С.ПодразделениеОрганизации = ДанныеПодразделения.Наименование;
			Пакет.ДанныеДД.FromDepartmentId = ДанныеПодразделения.Id;
		КонецЕсли;
		
	Иначе
		
		Если Вид = "Получатель" Тогда
			
			Если НЕ ЗначениеЗаполнено(Подразделение) ИЛИ Подразделение.Ссылка.ID_ВладелецПодразделения<>Получатель.ID Тогда
				Пакет.ДанныеДД.ToDepartmentId = Неопределено;
			Иначе
				Пакет.ДанныеДД.ToDepartmentId = Подразделение.Id;
			КонецЕсли;
			
		ИначеЕсли Вид = "Отправитель" Тогда			
			
			Если НЕ ЗначениеЗаполнено(Подразделение) ИЛИ Подразделение.Ссылка.ID_ВладелецПодразделения<>Отправитель.ID Тогда				
				Пакет.ДанныеДД.FromDepartmentId = Неопределено;
			Иначе				
				Пакет.ДанныеДД.FromDepartmentId = Подразделение.Id;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ОсновнаяФорма().Параметры.Использовать1СЭДО Тогда
		ПодключитьОбработчикОжидания("ОбработчикПослеОткрытияФормы", 0.1, Истина);		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработчикПослеОткрытияФормы()
	
	ПолучитьДанныеПоПодразделениям_1СЭДО();
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьДанныеПоПодразделениям_1СЭДО(БезусловноеПолучениеДанных=Ложь)
	
	Если НЕ ОсновнаяФорма().Параметры.Использовать1СЭДО Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Пакет.ДанныеДД.FromDepartmentId) ИЛИ ЗначениеЗаполнено(Пакет.ДанныеДД.ToDepartmentId) ИЛИ БезусловноеПолучениеДанных Тогда			
		
		МассивСсылок = Новый Массив;
		МассивСсылок.Добавить(Пакет.Данные1С.ПрофильНастроекЭДО);
		МассивСсылок.Добавить(Пакет.Данные1С.СоглашениеОбИспользованииЭДО);
		
		ДополнительныеПараметры = Новый Структура("ИмяСобытия, МассивСсылок", "Диадок_ПакетДокументов_Отправка_ЗагрузкаПодразделений", МассивСсылок);
		ОписаниеОповещения = ОсновнаяФорма().НовыйОписаниеОповещения("ПолучитьМассивСтруктурПодразделений_1СЭДО", ОсновнаяФорма().Модуль_РаботаСКомпонентой(), ДополнительныеПараметры);
		ОсновнаяФорма().ВыполнитьДействиеПослеАвторизации(ОписаниеОповещения);
				
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СформироватьДеревоПодразделенийНаСервере_1СЭДО(ПараметрОбработкиОповещения)
	
	Для Индекс = 0 По ПараметрОбработкиОповещения.МассивСсылок.ВГраница() Цикл
		
		Ссылка = ПараметрОбработкиОповещения.МассивСсылок[Индекс];
		МассивСтруктурПодразделений = ПараметрОбработкиОповещения.МассивДанных[Индекс];
		
		Если МассивСтруктурПодразделений.Количество() > 0 Тогда
			Дерево = ОбработкаОбъект().ЭДО_Преобразование_МассивСтруктурВДеревоЗначений(МассивСтруктурПодразделений,"ID_РодительПодразделения","");
		Иначе		
			Дерево = Новый ДеревоЗначений;
			Дерево.Колонки.Добавить("Наименование");
			Дерево.Колонки.Добавить("ID");
		КонецЕсли;
		
		Если ТипЗнч(Ссылка) = Тип("СправочникСсылка.ПрофилиНастроекЭДО") Тогда
			
			мДеревоПодразделений = РеквизитФормыВЗначение("ДеревоПодразделенийОтправителя");
			мДеревоПодразделений.Строки.Очистить();
			ОбработкаОбъект().ЗаполнитьСтрокиДерева(Дерево,мДеревоПодразделений);
			ЗначениеВРеквизитФормы(мДеревоПодразделений,"ДеревоПодразделенийОтправителя");
			
			СтрокаДерева = Дерево.Строки.Найти(Пакет.ДанныеДД.FromDepartmentId, "ID", Истина);
			
			Если СтрокаДерева <> Неопределено Тогда
				ПодразделениеОтправителя = СтрокаДерева.Наименование;
			Иначе
				Пакет.ДанныеДД.FromDepartmentId = "";
			КонецЕсли;
			
		ИначеЕсли ТипЗнч(Ссылка) = Тип("СправочникСсылка.СоглашенияОбИспользованииЭД") Тогда
			
			мДеревоПодразделений = РеквизитФормыВЗначение("ДеревоПодразделенийПолучателя");
			мДеревоПодразделений.Строки.Очистить();
			ОбработкаОбъект().ЗаполнитьСтрокиДерева(Дерево,мДеревоПодразделений);
			ЗначениеВРеквизитФормы(мДеревоПодразделений,"ДеревоПодразделенийПолучателя");
			
			СтрокаДерева = Дерево.Строки.Найти(Пакет.ДанныеДД.ToDepartmentId, "ID", Истина);
			
			Если СтрокаДерева <> Неопределено Тогда				
				ПодразделениеПолучателя = СтрокаДерева.Наименование;
			Иначе
				Пакет.ДанныеДД.ToDepartmentId = "";
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры
