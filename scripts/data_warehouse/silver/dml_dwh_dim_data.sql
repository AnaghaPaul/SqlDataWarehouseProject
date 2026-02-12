/*Update HOLIDAY Field of In dimension - only included global holidays*/
		    /* New Years Day - January 1 */
		    UPDATE silver.dwh_dim_date
		        SET [holiday_name] = 'New Year''s Day'
		    WHERE [month] = 1 AND [day_of_month] = 1
		
		    /* Valentine's Day - February 14 */
		    UPDATE silver.dwh_dim_date
		        SET [holiday_name] = 'Valentine''s Day'
		    WHERE
		        [month] = 2 AND
		        [day_of_month] = 14
		
		    /* Mother's Day - Second Sunday of May */
		    UPDATE silver.dwh_dim_date
		        SET [holiday_name] = 'Mother''s Day'
		    WHERE
		        [month] = 5 AND
		        [day_of_week] = 'Sunday' AND
		        [day_of_week_in_month] = 2
		
		    /* Father's Day - Third Sunday of June */
		    UPDATE silver.dwh_dim_date
		        SET [holiday_name] = 'Father''s Day'
		    WHERE
		        [month] = 6 AND
		        [day_of_week] = 'Sunday' AND
		        [day_of_week_in_month] = 3
		
		    /* Halloween - 10/31 */
		    UPDATE silver.dwh_dim_date
		        SET [holiday_name] = 'Halloween'
		    WHERE
		        [month] = 10 AND
		        [day_of_month] = 31
		    
		    /* Thanksgiving - Fourth THURSDAY in November */
		    UPDATE silver.dwh_dim_date
		        SET [holiday_name] = 'Thanksgiving Day'
		    WHERE
		        [month] = 11 AND
		        [day_of_week] = 'Thursday' AND
		        [day_of_week_in_month] = 4
		
		    /* Christmas */
		    UPDATE silver.dwh_dim_date
		        SET [holiday_name] = 'Christmas Day'
		    WHERE [month] = 12 AND
		          [day_of_month]  = 25
		    
		    
		    --set flag for holidays in Dimension
		    UPDATE silver.dwh_dim_date
		        SET is_holiday = CASE WHEN holiday_name IS NULL THEN 0
		                                WHEN holiday_name IS NOT NULL THEN 1 END

			-- ---------------------------------------------------------------------------------
						
			
			/* Add Fiscal Calendar columns into table DimDate */
			
			ALTER TABLE silver.dwh_dim_date ADD
			    [fiscal_day_of_year] VARCHAR(3),
			    [fiscal_week_of_year] VARCHAR(3),
			    [fiscal_month] VARCHAR(2), 
			    [fiscal_quarter] CHAR(1),
			    [fiscal_quarter_name] VARCHAR(9),
			    [fiscal_year] CHAR(4),
			    [fiscal_year_name] CHAR(7),
			    [fiscal_month_year] CHAR(10),
			    [fiscal_mmyyyy] CHAR(6),
			    [fiscal_first_day_of_month] DATE,
			    [fiscal_last_day_of_month] DATE,
			    [fiscal_first_day_of_quarter] DATE,
			    [fiscal_last_day_of_quarter] DATE,
			    [fiscal_first_day_of_year] DATE,
			    [fiscal_last_day_of_year] DATE
			
			GO
			
			/***************************************************************************
			The following section needs to be populated for defining the fiscal calendar
			***************************************************************************/
			
			DECLARE
			    @dt_fiscal_year_start SMALLDATETIME = 'December 29, 2010',   -- Fiscal year start
			    @fiscal_year INT = 2011,                            -- First fiscal year after start
			    @last_year INT = 2100,                              -- Ending year for the range
			    @first_leap_year_in_period INT = 2012                  -- First leap year after start
			
			
			/*****************************************************************************************/
			
			DECLARE
			    @i_temp INT,
			    @leap_week INT,
			    @current_date DATETIME,
			    @fiscal_day_of_year INT,
			    @fiscal_week_of_year INT,
			    @fiscal_month INT,
			    @fiscal_quarter INT,
			    @fiscal_quarter_name VARCHAR(10),
			    @fiscal_year_name VARCHAR(7),
			    @leap_year INT,
			    @fiscal_first_day_of_year DATE,
			    @fiscal_first_day_of_quarter DATE,
			    @fiscal_first_day_of_month DATE,
			    @fiscal_last_day_of_year DATE,
			    @fiscal_last_day_of_quarter DATE,
			    @fiscal_last_day_of_month DATE
			
			/*Holds the years that have 455 in last quarter*/
			
			DECLARE @leap_table TABLE (leap_year INT)
			
			/*TABLE to contain the fiscal year calendar*/
			
			DECLARE @tb TABLE
			(
			    [period_date] DATETIME,
			    [fiscal_day_of_year] VARCHAR(3),
			    [fiscal_week_of_year] VARCHAR(3),
			    [fiscal_month] VARCHAR(2), 
			    [fiscal_quarter] VARCHAR(1),
			    [fiscal_quarter_name] VARCHAR(9),
			    [fiscal_year] VARCHAR(4),
			    [fiscal_year_name] VARCHAR(7),
			    [fiscal_month_year] VARCHAR(10),
			    [fiscal_mmyyyy] VARCHAR(6),
			    [fiscal_first_day_of_month] DATE,
			    [fiscal_last_day_of_month] DATE,
			    [fiscal_first_day_of_quarter] DATE,
			    [fiscal_last_day_of_quarter] DATE,
			    [fiscal_first_day_of_year] DATE,
			    [fiscal_last_day_of_year] DATE
			)
			
			/*Populate the table with all leap years*/
			
			SET @leap_year = @first_leap_year_in_period
			WHILE (@leap_year < @last_year)
			    BEGIN
			        INSERT INTO @leap_table VALUES (@leap_year)
			        SET @leap_year = @leap_year + 6
			    END
			
			/*Initiate parameters before loop*/
			
			SET @current_date = @dt_fiscal_year_start
			SET @fiscal_day_of_year = 1
			SET @fiscal_week_of_year = 1
			SET @fiscal_month = 1
			SET @fiscal_quarter = 1
			SET @fiscal_week_of_year = 1
			
			IF (EXISTS (SELECT * FROM @leap_table WHERE @fiscal_year = @leap_year))
			    BEGIN
			        SET @leap_week = 1
			    END
			    ELSE
			    BEGIN
			        SET @leap_week = 0
			    END
			
			/*******************************************************************************************/
			
			/* Loop on days in interval*/
			
			WHILE (DATEPART(yy,@current_date) <= @last_year)
			BEGIN
			    
			/*SET fiscal Month*/
			    SELECT @fiscal_month = CASE
			
			        /*Use this section for a 4-4-5 calendar.  
			        Every leap year the result will be a 4-5-5*/
			        WHEN @fiscal_week_of_year BETWEEN 1 AND 4 THEN 1 /*4 weeks*/
			        WHEN @fiscal_week_of_year BETWEEN 5 AND 8 THEN 2 /*4 weeks*/
			        WHEN @fiscal_week_of_year BETWEEN 9 AND 13 THEN 3 /*5 weeks*/
			        WHEN @fiscal_week_of_year BETWEEN 14 AND 17 THEN 4 /*4 weeks*/
			        WHEN @fiscal_week_of_year BETWEEN 18 AND 21 THEN 5 /*4 weeks*/
			        WHEN @fiscal_week_of_year BETWEEN 22 AND 26 THEN 6 /*5 weeks*/
			        WHEN @fiscal_week_of_year BETWEEN 27 AND 30 THEN 7 /*4 weeks*/
			        WHEN @fiscal_week_of_year BETWEEN 31 AND 34 THEN 8 /*4 weeks*/
			        WHEN @fiscal_week_of_year BETWEEN 35 AND 39 THEN 9 /*5 weeks*/
			        WHEN @fiscal_week_of_year BETWEEN 40 AND 43 THEN 10 /*4 weeks*/
			        WHEN @fiscal_week_of_year BETWEEN 44 AND (47+@leap_week) THEN 11 /*4 weeks (5 weeks on leap year)*/
			        WHEN @fiscal_week_of_year BETWEEN (48 + @leap_week) AND (52 + @leap_week) THEN 12 /*5 weeks*/
			        
			    END
			
			    /*SET Fiscal Quarter*/
			    SELECT @fiscal_quarter = CASE 
			        WHEN @fiscal_month BETWEEN 1 AND 3 THEN 1
			        WHEN @fiscal_month BETWEEN 4 AND 6 THEN 2
			        WHEN @fiscal_month BETWEEN 7 AND 9 THEN 3
			        WHEN @fiscal_month BETWEEN 10 AND 12 THEN 4
			    END
			    
			    SELECT @fiscal_quarter_name = CASE 
			        WHEN @fiscal_month BETWEEN 1 AND 3 THEN 'First'
			        WHEN @fiscal_month BETWEEN 4 AND 6 THEN 'Second'
			        WHEN @fiscal_month BETWEEN 7 AND 9 THEN 'Third'
			        WHEN @fiscal_month BETWEEN 10 AND 12 THEN 'Fourth'
			    END
			    
			    /*Set Fiscal Year Name*/
			    SELECT @fiscal_year_name = 'FY ' + CONVERT(VARCHAR, @fiscal_year)
			
			    INSERT INTO @tb
			    (
			        period_date,
			        fiscal_day_of_year,
			        fiscal_week_of_year,
			        fiscal_month,
			        fiscal_quarter,
			        fiscal_quarter_name,
			        fiscal_year,
			        fiscal_year_name
			    ) VALUES (
			        @current_date,
			        @fiscal_day_of_year,
			        @fiscal_week_of_year,
			        @fiscal_month,
			        @fiscal_quarter,
			        @fiscal_quarter_name,
			        @fiscal_year,
			        @fiscal_year_name
			    )
			
			    /*SET next day*/
			    SET @current_date = DATEADD(dd, 1, @current_date)
			    SET @fiscal_day_of_year = @fiscal_day_of_year + 1
			    SET @fiscal_week_of_year = ((@fiscal_day_of_year-1) / 7) + 1
			
			
			    IF (@fiscal_week_of_year > (52+@leap_week))
			    BEGIN
			        /*Reset a new year*/
			        SET @fiscal_day_of_year = 1
			        SET @fiscal_week_of_year = 1
			        SET @fiscal_year = @fiscal_year + 1
			        IF (EXISTS (SELECT * FROM @leap_table WHERE @fiscal_year = leap_year))
			        BEGIN
			            SET @leap_week = 1
			        END
			        ELSE
			        BEGIN
			            SET @leap_week = 0
			        END
			    END
			END
			
			/********************************************************************************************/
			
			/*Set first and last days of the fiscal months*/
			UPDATE @tb
			SET
			    fiscal_first_day_of_month = minmax.start_date,
			    fiscal_last_day_of_month = minmax.end_date
			FROM
			    @tb t,
			    (
			        SELECT
			            fiscal_month,
			            fiscal_quarter,
			            fiscal_year,
			            MIN(period_date) AS start_date, 
			            MAX(period_date) AS end_date
			        FROM @tb
			        GROUP BY
			            fiscal_month,
			            fiscal_quarter,
			            fiscal_year
			    ) minmax
			
			WHERE
			    t.fiscal_month = minmax.fiscal_month AND
			    t.fiscal_quarter = minmax.fiscal_quarter AND
			    t.fiscal_year = minmax.fiscal_year 
			
			/*Set first and last days of the fiscal quarters*/
			
			UPDATE @tb
			SET fiscal_first_day_of_quarter = minmax.start_date,
			    fiscal_last_day_of_quarter = minmax.end_date
			FROM
			    @tb t,
			    (
			        SELECT
			            fiscal_quarter,
			            fiscal_year,
			            MIN(period_date) as start_date,
			            MAX(period_date) as end_date
			        FROM
			            @tb
			        GROUP BY
			            fiscal_quarter,
			            fiscal_year
			    ) minmax
			WHERE
			    t.fiscal_quarter = minmax.fiscal_quarter AND
			    t.fiscal_year = minmax.fiscal_year 
			
			/*Set first and last days of the fiscal years*/
			
			UPDATE @tb
			SET
			    fiscal_first_day_of_year = minmax.start_date,
			    fiscal_last_day_of_year = minmax.end_date
			FROM
			@tb t,
			(
			    SELECT fiscal_year, min(period_date) as start_date, max(period_date) as end_date
			    FROM @tb
			    GROUP BY fiscal_year
			) minmax
			WHERE
			    t.fiscal_year = minmax.fiscal_year 
			
			/*Set FiscalYearMonth*/
			UPDATE @tb
			SET
			    fiscal_month_year = 
			        CASE fiscal_month
			        WHEN 1 THEN 'Jan'
			        WHEN 2 THEN 'Feb'
			        WHEN 3 THEN 'Mar'
			        WHEN 4 THEN 'Apr'
			        WHEN 5 THEN 'May'
			        WHEN 6 THEN 'Jun'
			        WHEN 7 THEN 'Jul'
			        WHEN 8 THEN 'Aug'
			        WHEN 9 THEN 'Sep'
			        WHEN 10 THEN 'Oct'
			        WHEN 11 THEN 'Nov'
			        WHEN 12 THEN 'Dec'
			        END + '-' + CONVERT(VARCHAR, fiscal_year)
			
			/*Set FiscalMMYYYY*/
			UPDATE @tb
			SET
			    fiscal_mmyyyy = RIGHT('0' + CONVERT(VARCHAR, fiscal_month),2) + CONVERT(VARCHAR, fiscal_year)
			
			/********************************************************************************************/
			
			UPDATE silver.dwh_dim_date
			    SET fiscal_day_of_year = a.fiscal_day_of_year
			      , fiscal_week_of_year = a.fiscal_week_of_year
			      , fiscal_month = a.fiscal_month
			      , fiscal_quarter = a.fiscal_quarter
			      , fiscal_quarter_name = a.fiscal_quarter_name
			      , fiscal_year = a.fiscal_year
			      , fiscal_year_name = a.fiscal_year_name
			      , fiscal_month_year = a.fiscal_month_year
			      , fiscal_mmyyyy = a.fiscal_mmyyyy
			      , fiscal_first_day_of_month = a.fiscal_first_day_of_month
			      , fiscal_last_day_of_month = a.fiscal_last_day_of_month
			      , fiscal_first_day_of_quarter = a.fiscal_first_day_of_quarter
			      , fiscal_last_day_of_quarter = a.fiscal_last_day_of_quarter
			      , fiscal_first_day_of_year = a.fiscal_first_day_of_year
			      , fiscal_last_day_of_year = a.fiscal_last_day_of_year
			FROM @tb a
			    INNER JOIN silver.dwh_dim_date b ON a.period_date = b.[date]
			
			-- -----------------------------------------------------------------------------------------------------------
						
				
