-- ====================================================================================
-- dwh_dim_supplementary calendar
-- contains global holidays
-- country specific holidays
-- seasons
-- ===================================================================================
-- Truncate
TRUNCATE TABLE silver.dwh_dim_supplementary_calendar;

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
DECLARE @start_date DATETIME = '2014-12-29';
DECLARE @end_date DATETIME = '2100-01-01';
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
DECLARE @current_date DATETIME = @start_date;

-- As the presence of the business expands, new countries can be added to this list
-- Country list
DECLARE @countries TABLE (country CHAR(20));
INSERT INTO @countries VALUES ('Canada'), ('United States'), ('Germany'), ('United Kingdom'), ('France'), ('Australia');

-- Temporary variables
DECLARE @country CHAR(20);
DECLARE @holiday_flag BIT;
DECLARE @religious_holiday_flag BIT;
DECLARE @holiday_name VARCHAR(100);
DECLARE @season VARCHAR(20);

-- Proceed only when start_date or current date less than end date
WHILE @current_date <= @end_date

BEGIN
    DECLARE country_cursor CURSOR FOR SELECT country FROM @countries;
    OPEN country_cursor;
    FETCH NEXT FROM country_cursor INTO @country;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        -- Reset default values
        SET @holiday_flag = 0;
        SET @religious_holiday_flag = 0;
        SET @holiday_name = NULL;

  -- =============================================Set Season logic =================================================================
  -- Season logic
		SET @season = CASE 
                 WHEN MONTH(@current_date) IN (12, 1, 2) THEN 'Winter'
                 WHEN MONTH(@current_date) IN (3, 4, 5) THEN 'Spring'
                 WHEN MONTH(@current_date) IN (6, 7, 8) THEN 'Summer'
                 WHEN MONTH(@current_date) IN (9, 10, 11) THEN 'Autumn'
              END;
-- ==========================================Holiday logic ========================================================================
-- The holidays are further split into global holidays and country specific holidays
-- ==================================================================================================================================
-- ========================= Global Holidays ==========================================
    -- Reset to default
		SET @holiday_flag = 0;
		SET @religious_holiday_flag = 0;
		SET @holiday_name = NULL;

		-- ---------------------------------------------------------------------------------
		-- January
		-- ---------------------------------------------------------------------------------

		-- New Year's Day: January 1
		IF MONTH(@current_date) = 1 AND DAY(@current_date) = 1
		BEGIN
			SET @holiday_flag = 1;
			SET @religious_holiday_flag = 0;
			SET @holiday_name = 'New Year''s Day';
		END
      
		---- Blue Monday : 3rd monday of january
		ELSE IF @country IN ('US','CA','GB') 
			 AND MONTH(@current_date) = 1 
			 AND DATEPART(WEEKDAY, @current_date) = 2
			 AND ((DAY(@current_date) - 1) / 7) + 1 = 3
		BEGIN
			SET @holiday_flag = 1;-- ?
			SET @religious_holiday_flag = 0;
			SET @holiday_name = 'Blue Monday';
			END
        
		-- ---------------------------------------------------------------------
		-- February
		-- ---------------------------------------------------------------------
		-- Black history month-starts from february 1 (need to be added)

        
		-- Galentine's day
		ELSE IF MONTH(@current_date)= 2 AND DAY(@current_date)= 13
		BEGIN
			SET @holiday_flag = 1;
			SET @religious_holiday_flag=0;
			SET @holiday_name = 'Galentines day'
		END
        
		-- Valentine's Day
		ELSE IF MONTH(@current_date)=2 AND DAY(@current_date) =14
		BEGIN
			SET @holiday_flag = 1;
			SET @religious_holiday_flag =0;
			SET @holiday_name='Valentines Day'
		END

    -- -----------------------------------------------------------------------
		--March
		-- ------------------------------------------------------------------------
    -- International Women's Day March 8
    ELSE IF MONTH(@current_date) = 3 AND DAY(@current_date) = 8
    BEGIN
        SET @holiday_flag = 1;
        SET @religious_holiday_flag = 0;
        SET @holiday_name = 'International Womens Day'
    END
          
    -- First Day of spring
    ELSE IF MONTH(@current_date) = 3 AND DAY(@current_date) = 20
    BEGIN
          SET @holiday_flag = 1;
          SET @religious_holiday_flag = 0;
          SET @holiday_name = 'First Day of Spring'
    END
    -- --------------------------------------------------------------------
    -- April
    -- --------------------------------------------------------------------
		-- International Labor Day: May 1
		ELSE IF MONTH(@current_date) = 5 AND DAY(@current_date) = 1
		BEGIN
			SET @holiday_flag = 1;
			SET @religious_holiday_flag = 0;
			SET @holiday_name = 'International Labor Day';
		END

    -- 
		-- Christmas: December 25
		ELSE IF MONTH(@current_date) = 12 AND DAY(@current_date) = 25
		BEGIN
			SET @holiday_flag = 1;
			SET @religious_holiday_flag = 1;
			SET @holiday_name = 'Christmas Day';
		END
		-- Boxing Day: December 26 (common in UK, Canada, Australia)
		ELSE IF MONTH(@current_date) = 12 AND DAY(@current_date) = 26
		BEGIN
			SET @holiday_flag = 1;
			SET @religious_holiday_flag = 0;
			SET @holiday_name = 'Boxing Day';
		END


-- --------------------------------------------------------------------------------------------
-- United States
--**************
-- Independance day

-- --------------------------------------------------------------------------------------------
        -- Country-specific holidays (example)
        IF @country = 'United States'
        BEGIN
            IF MONTH(@current_date) = 7 AND DAY(@current_date) = 4
            BEGIN
                SET @holiday_flag = 1;
                SET @religious_holiday_flag = 0;
                SET @holiday_name = 'Independence Day';
            END
        END
-- ----------------------------------------------------------------------
-- Canada
-- ----------------------------------------------------------------------
-- Canada Day
        IF @country = 'Canada'
        BEGIN
            IF MONTH(@current_date) = 7 AND DAY(@current_date) = 1
            BEGIN
                SET @holiday_flag = 1;
                SET @religious_holiday_flag = 0;
                SET @holiday_name = 'Canada Day';
            END
        END

-- ---------------------------------------------------------------------

        -- Insert into supplementary calendar
        INSERT INTO silver.dwh_dim_supplementary_calendar
        (date_key, country, holiday_flag, religious_holiday_flag, holiday_name, season)
        VALUES
        (CONVERT(INT, CONVERT(CHAR(8), @current_date, 112)), @country, @holiday_flag, @religious_holiday_flag, @holiday_name, @season);

        FETCH NEXT FROM country_cursor INTO @country;
    END

    CLOSE country_cursor;
    DEALLOCATE country_cursor;

    SET @current_date = DATEADD(DAY, 1, @current_date);
END
