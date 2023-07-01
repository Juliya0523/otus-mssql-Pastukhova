/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT [StockItemID]
      ,[StockItemName]    
  FROM [WideWorldImporters].[Warehouse].[StockItems]
  where ([StockItemName] like '%urgent%') or ([StockItemName] like 'Animal%')

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT  
	t.[SupplierID],
    t.[SupplierName]    
FROM [WideWorldImporters].[Purchasing].[Suppliers] t
	left join [WideWorldImporters].[Purchasing].[PurchaseOrders] t1
		on  t1.[SupplierID] = t.[SupplierID]		
where t1.[OrderDate] is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

--/*постраничная выборка
declare 
	@pagesize bigint = 100,
	@pagenum bigint = 11;
--*/постраничная выборка

	SELECT  
	t.[OrderID] as [OrderID],
	t.[OrderDate] as [Order Date],
	case 
		when month(t.[OrderDate])= 1 then  'Январь'
		when month(t.[OrderDate])= 2 then  'Февраль'
		when month(t.[OrderDate])= 3 then  'Март'
		when month(t.[OrderDate])= 4 then  'Апрель'
		when month(t.[OrderDate])= 5 then  'Май'
		when month(t.[OrderDate])= 6 then  'Июнь'
		when month(t.[OrderDate])= 7 then  'Июль'
		when month(t.[OrderDate])= 8 then  'Август'
		when month(t.[OrderDate])= 9 then  'Сентябрь'
		when month(t.[OrderDate])= 10 then 'Октябрь'
		when month(t.[OrderDate])= 11 then 'Ноябрь'
		when month(t.[OrderDate])= 12 then 'Декабрь'
	end as [Month],
	case 
		when month(t.[OrderDate]) between 1 and 3 then   '1 квартал'
		when month(t.[OrderDate]) between 4 and 6 then   '2 квартал'
		when month(t.[OrderDate]) between 4 and 9 then   '3 квартал'
		when month(t.[OrderDate]) between 10 and 12 then '4 квартал'
	end as [Quarter],
	case 
		when month(t.[OrderDate]) between 1 and 4 then  '1 треть года'
		when month(t.[OrderDate]) between 5 and 8 then  '2 треть года'
		when month(t.[OrderDate]) between 9 and 12 then '3 треть года'
	end as [Third of the year],
	t3.[CustomerName] as [Customer Name]
  FROM [WideWorldImporters].[Sales].[Orders] t
	  left join [WideWorldImporters].[Sales].[OrderLines] t1
		on t.[OrderID] = t1.[OrderID]
	  left join [WideWorldImporters].[Sales].[Customers] t3
		on t.[CustomerID] = t3.[CustomerID]
  where ((t1.[UnitPrice] > 200) or ([Quantity]>20)) and (t.[PickingCompletedWhen] is not null)
  order by  
	[Quarter], [Third of the year], [Order Date] asc

--/*--постраничная выборка
offset (@pagenum-1)*@pagesize rows fetch next @pagesize rows only;
--*/--постраничная выборка


/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT  
	t2.[DeliveryMethodName] as [Delivery Method Name],
    t.[ExpectedDeliveryDate] as [Expected Delivery Date],
	t1.[SupplierName] as [Supplier Name],
	t3.[FullName] as [Contact Person]
FROM [WideWorldImporters].[Purchasing].[PurchaseOrders] t
	left join [WideWorldImporters].[Purchasing].[Suppliers] t1
		on t.SupplierID = t1.SupplierID
	left join [WideWorldImporters].[Application].[DeliveryMethods] t2
		on t.[DeliveryMethodID] = t2.DeliveryMethodID  
	left join [WideWorldImporters].[Application].[People] t3
		on t.ContactPersonID = t3.PersonID

WHERE 
	t.[ExpectedDeliveryDate] like '2013-01%'
	and (t2.DeliveryMethodName = 'Air Freight'
		or t2.DeliveryMethodName = 'Refrigerated Air Freight')
	and t.[IsOrderFinalized] = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT 
	t.[OrderDate] as [Order Date],
	t1.[FullName] as [Sales person],
	t2.[FullName] as [Employee]
FROM [WideWorldImporters].[Sales].[Orders] t
	left join [WideWorldImporters].[Application].[People] t1
		on t.SalespersonPersonID=t1.PersonID
			and t1.IsSalesperson = 1
	left join [WideWorldImporters].[Application].[People] t2
		on t.SalespersonPersonID=t2.PersonID
			and t2.IsEmployee = 1
ORDER BY 
	t.[OrderDate]
offset 73585 rows fetch first 10 rows only

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT 
	t.[ContactPersonID],
	t2.[FullName],
	t2.[PhoneNumber]
FROM [WideWorldImporters].[Sales].[Orders] t
	left join [WideWorldImporters].[Sales].[OrderLines] t1
		on t.OrderID = t1.OrderID
	left join [WideWorldImporters].[Application].[People] t2
		on t.[ContactPersonID] = t2.[PersonID]
WHERE t1.[StockItemID] = 224
GROUP BY 
t.[ContactPersonID],
t2.[FullName],
t2.[PhoneNumber]
