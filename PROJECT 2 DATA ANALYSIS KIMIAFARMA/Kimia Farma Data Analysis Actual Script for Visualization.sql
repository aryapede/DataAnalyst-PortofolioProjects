use sales
select * from pelanggan
select * from penjualan
select * from barang

-- 1. mencari total pendapatan dan total item terjual berdasarkan cabang sales 

select b.cabang_sales, sum(a.total) as total_penjualan, sum(a.jumlah_barang) as total_item_terjual
from penjualan a join pelanggan b on a.id_customer = b.id_customer
group by b.cabang_sales
order by total_penjualan

-- 2 mencari performa pernjualan dari masing-masing cabang sales

select b.cabang_sales, sum(a.jumlah_barang) as total_penjualan
from penjualan a join pelanggan b on a.id_customer = b.id_customer
group by  b.cabang_sales
order by total_penjualan

--3 mencari total item terjual berdasarkan produk yang terjual

select b.nama_barang, sum(a.total) as total_penjualan, sum(a.jumlah_barang) as total_item_terjual
from penjualan a join barang b on a.id_barang = b.kode_barang
group by b.nama_barang
order by total_item_terjual

--4 mencari total item terjual berdasarkan nama brand

select b.lini, sum(a.total) as total_penjualan, sum(a.jumlah_barang) as total_item_terjual
from penjualan a join barang b on a.id_barang = b.kode_barang
group by b.lini
order by total_item_terjual

--5 melihat performa penjualan per bulannya

select tanggal, sum(total) as total_penjualan, sum(jumlah_barang) as total_item_terjual
from penjualan 
group by tanggal
order by tanggal

--6 total pendapatan dan item terjual

select sum(total) total_sales, sum(jumlah_barang) product_sold
from penjualan