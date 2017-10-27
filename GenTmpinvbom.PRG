Create Table TmpInvBom (Inv_ID c (20),;
						Inv_nth_dt n (7,5),;
						sequence n (7,5),;
						nth_dtl n (7,5),;
						So_id c (20),;
						Order_no c(60),;
						so_nth_dtl n (7,5),;
						Bom_id c (27),;
						Bom_nth_dt n (7,5),;
						Item_type c (20),;
						product_id c (27),;
						product_co c (27),;
						product_na c (60),;
						custom_cod c (20),;
						origin c (20),;
						desc m,;																								
						color_code c (8),;
						color_eng c (50),;
						color_chs c (50),;
						size c (10),;
						quantity n (14,4),;
						ctn_unit c (6),;
						unit_price n (14,4),;
						amount n (15,4),;
						Group_ID c (2))
Select TmpInvbom
Index on Upper(Inv_ID) tag Inv_ID
Index on Upper(Inv_ID)+Str(Inv_nth_dt,7,5) tag Inv_key
Index on Upper(Inv_ID)+Str(Sequence,7,5) tag Order_ID
Index on Upper(Inv_ID)+Upper(So_ID) tag Inv_So
Index on Upper(Inv_ID)+Upper(Order_no) tag Inv_order
Index on Upper(Inv_ID)+Upper(Order_no)+Upper(Product_Co) Tag InvSo_Prod
Index on Upper(So_ID) tag So_ID
Index on Upper(So_ID)+Str(So_Nth_dtl) tag So_key
Index on Upper(So_ID)+Upper(Product_co) tag So_pcode
Index on Upper(Product_ID) tag Product_ID
Index on Upper(Group_ID) tag Group_ID
