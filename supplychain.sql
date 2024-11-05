ALTER TABLE DataCoSupplyChainDataset
DROP COLUMN Order_Zipcode, Product_Description
SELECT * FROM  DataCoSupplyChainDataset

-- 1. Analisis Pengiriman

-- A. Berapa persentase pengiriman yang terlambat?

SELECT
	(SUM( CASE WHEN Late_delivery_risk = 1  THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS late_delivery_percentage
FROM DataCoSupplyChainDataset

-- B. Bagaimana perbandingan antara Days for shipping (real) dan Days for shipment (scheduled) pada pesanan yang terlambat?

SELECT 
    AVG(Days_for_shipping_real) AS avg_real_shipping_days,
    AVG(Days_for_shipment_scheduled) AS avg_scheduled_shipping_days
FROM 
    DataCoSupplyChainDataset
WHERE 
    Late_delivery_risk = 1;

-- c. Apakah ada hubungan antara Shipping Mode dengan jumlah hari pengiriman yang dibutuhkan?

SELECT
	Shipping_Mode,
	AVG(Days_for_shipping_real) AS Real_shipping_days
FROM DataCoSupplyChainDataset
Group by Shipping_Mode;

-- 2. Analisis Penjualan dan Keuntungan

-- a. Bagaimana pengaruh Order Item Discount Rate terhadap Order Item Profit Ratio dan Order Profit Per Order?

-- merubah order_item_discount_rate 
UPDATE DataCoSupplyChainDataset
SET Order_Item_Discount_Rate = (Order_Item_Discount_Rate / 1000000000) * 100;

SELECT 
    Order_Item_Discount_Rate,
    AVG(Order_Item_Profit_Ratio) AS avg_profit_ratio,
    AVG(Order_Profit_Per_Order) AS avg_profit_per_order
FROM 
    DataCoSupplyChainDataset
GROUP BY 
    Order_Item_Discount_Rate
ORDER BY 
    Order_Item_Discount_Rate DESC;

-- b. Produk atau kategori apa yang memberikan Benefit per order tertinggi?

SELECT
TOP 10
	Category_Name,
	Product_Name,
	AVG(Benefit_per_order) as avg_benefit_per_order
FROM DataCoSupplyChainDataset
Group by Category_Name,
	Product_Name
Order by avg_benefit_per_order desc;

-- c. Berapa rata-rata Sales per customer di setiap kota?

SELECT 
TOP 7
	Customer_City,
	AVG(Sales_per_customer) as avg_sales_per_customer
FROM DataCoSupplyChainDataset
Group by Customer_City
Order by avg_sales_per_customer desc;

-- 3. Segmentasi Pelanggan

-- a. Apakah ada perbedaan rata-rata Sales per customer di setiap Customer Segment?

SELECT
	Customer_Segment,
	AVG(Sales_per_customer) as avg_sales_per_customer
FROM DataCoSupplyChainDataset
Group by Customer_Segment
Order by avg_sales_per_customer desc;

-- b. Negara atau kota mana yang memiliki jumlah pesanan tertinggi?

SELECT Customer_Country, Customer_City, COUNT(Order_Id) as total_orders
FROM DataCoSupplyChainDataset
GROUP BY Customer_Country, Customer_City
ORDER BY total_orders DESC;

-- c. Apa saja karakteristik pelanggan yang paling sering melakukan pesanan?

SELECT 
	Customer_Segment,
	Customer_Country,
	COUNT(Order_Id) as total_orders
FROM DataCoSupplyChainDataset
GROUP BY Customer_Segment, Customer_Country
ORDER BY total_orders DESC;

-- 4. Analisis Geografis

-- a. Apakah ada perbedaan dalam rata-rata Order Profit Per Order berdasarkan Order Region?

SELECT
	Order_Region,
	AVG(Order_Profit_Per_Order) as Profit_per_Order
FROM DataCoSupplyChainDataset
Group by Order_Region
Order by Profit_per_Order desc;

-- b. Bagaimana pengaruh lokasi terhadap waktu pengiriman dan status pengiriman?

SELECT
	Order_Region,
	AVG(Days_for_shipping_real) AS days_shipping_real,
	SUM(CASE WHEN Late_delivery_risk = 1 THEN 1 ELSE 0 END) AS late_deliveries
FROM DataCoSupplyChainDataset
GROUP BY Order_Region
ORDER BY days_shipping_real, late_deliveries desc;

-- 5. Kinerja Produk
-- a. Produk apa yang paling banyak dipesan berdasarkan Quantity?

SELECT
	Product_Name,
	SUM(Order_Item_Quantity) as total_quantity_ordered
FROM DataCoSupplyChainDataset
GROUP BY Product_Name
Order by total_quantity_ordered desc;

-- b. Apakah ada hubungan antara Product Price dan Order Item Profit Ratio?

SELECT
	Product_Price,
	AVG(Order_Item_Profit_Ratio) as Avg_Order_Profit_ratio
FROM DataCoSupplyChainDataset
Group by Product_Price
Order by Avg_Order_Profit_ratio desc;

-- c. Bagaimana distribusi status produk dan bagaimana hubungannya dengan pesanan?

SELECT
	Product_Status,
	COUNT(Order_Id) as total_OrderS
FROM DataCoSupplyChainDataset
GROUP BY Product_Status
ORDER BY total_OrderS DESC;

-- 6. Analisis Order dan Pengiriman

-- a. Berapa jumlah rata-rata hari antara order date dan shipping date?

SELECT
    AVG(DATEDIFF(DAY, shipping_date_DateOrders, order_date_DateOrders)) AS avg_days_to_ship
FROM 
    DataCoSupplyChainDataset;

-- b. Apakah terdapat hubungan antara Order Status dan Shipping Mode?

SELECT
	Order_Status,
	Shipping_Mode,
	COUNT(Order_Id) as total_orders
FROM DataCoSupplyChainDataset
Group by Order_Status, Shipping_Mode
Order by total_orders desc;

-- c. Berapa rata-rata Order Item Total di setiap Order State dan bagaimana pengaruhnya terhadap Order Status?

SELECT
	Order_state,
	Order_Status,
	COUNT(Order_Item_Total) as total_item_orders
FROM DataCoSupplyChainDataset
GROUP by Order_State, Order_Status
ORDER BY total_item_orders DESC;