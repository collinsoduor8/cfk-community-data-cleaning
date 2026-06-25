                 -- ==========================================
                 -- 1. PROGRAM ACTIVITIES TABLE CLEANING
                 -- ==========================================
SELECT * 
FROM cfk_health_visits;

CREATE VIEW health_visits AS
SELECT 
"VisitID", "Diagnosis",
    INITCAP("Service") AS service,

    -- Cleaning paid fee column
    CAST(
        CASE 
            WHEN "Fee Paid (KES)" = 'One Fifty' THEN '150'
            ELSE "Fee Paid (KES)"
        END AS INTEGER
    ) AS fee_paid,

    -- Cleaning follow up
    CASE
       WHEN LOWER("Follow Up Required?") = 'yes' THEN 'Yes'
       WHEN LOWER("Follow Up Required?") = 'no'  THEN 'No'
       ELSE 'Unknown' 
    END AS follow_up,

    -- Cleaning visit date
    CASE 
        -- Matches '2024-01-05' (Starts with 4-digit Year followed by a dash)
        WHEN "Visit Date" LIKE '____-%' 
            THEN TO_DATE("Visit Date", 'YYYY-MM-DD')

        -- Matches '01-02-2024' (Starts with 2-digit Day followed by a dash)
        WHEN "Visit Date" LIKE '__-%' 
            THEN TO_DATE("Visit Date", 'DD-MM-YYYY')

        -- Matches '05/01/2024' (Contains slashes)
        WHEN "Visit Date" LIKE '%/%/%' 
            THEN TO_DATE("Visit Date", 'DD/MM/YYYY')
            
        -- Matches 'Jan 12 2024' (Text month layout with spaces)
        ELSE TO_DATE("Visit Date", 'Mon DD YYYY')
    END AS visit_date,

   ----- cleaning beneficiary id
   CASE 
    WHEN "BeneficiaryID" = 'CFK999' THEN 'Unregistered'
    ELSE "BeneficiaryID"
END AS beneficiary_id,

---cleaning staff column
TRIM(INITCAP("Staff")) AS staff
FROM cfk_health_visits;

                      -- ==========================================
                      -- 2. PROGRAM ACTIVITIES TABLE CLEANING
                      -- ==========================================

SELECT *
FROM cfk_beneficiaries;

CREATE VIEW beneficiaries AS
SELECT
  "BeneficiaryID",
   "FullName" ,
    -- 1. CLEANING THE GENDER COLUMN
    CASE
        WHEN LOWER("Gender") IN ('f', 'female') THEN 'Female'
        WHEN LOWER("Gender") IN ('m', 'male') THEN 'Male'
        ELSE 'unknown'
    END AS gender,

    -- 2. FIXED BLANK AGES (Replaces blank age with 0 or keeping it clear)
    COALESCE("Age", 0) AS age,
    
    -- 3. FIXED VILLAGE TEXT CASING (Converts 'soweto east' -> 'Soweto East')
    INITCAP("Village") AS village,

    -- 4. CLEANING THE ACTIVE COLUMN (Handles text and numeric 1/0 flags)
    CASE 
        WHEN LOWER("Active") IN ('yes', '1') THEN 'Yes'
        WHEN LOWER("Active") IN ('no', '0') THEN 'No'
        ELSE 'Unknown'
    END AS active,
    
    -- 5. CLEANING THE PHONE COLUMN (Removes all spaces entirely)
    COALESCE(REPLACE("Phone", ' ', ''), 'No Phone') AS phone,
    
    "ProgramArea",
    
    -- 6. CLEANING THE REGISTRATION DATE COLUMN
    CASE
        -- Matches '2023-01-10' layout (YYYY-MM-DD)
        WHEN "RegistrationDate" LIKE '____-__-__' 
            THEN TO_DATE("RegistrationDate", 'YYYY-MM-DD')
        
        -- Matches '10/01/2023' or '2023/02/10' layout (Slashes present)
        WHEN "RegistrationDate" LIKE '%/%/%' 
            THEN CASE 
                -- If it starts with 4 characters before the slash (YYYY/MM/DD)
                WHEN "RegistrationDate" LIKE '____/%' THEN TO_DATE("RegistrationDate", 'YYYY/MM/DD')
                -- Otherwise treat it as standard Day/Month/Year (DD/MM/YYYY)
                ELSE TO_DATE("RegistrationDate", 'DD/MM/YYYY')
            END
            
        -- Matches text layouts that end in 2023 (e.g., 'Jan 2023' or 'March 2023')
        WHEN "RegistrationDate" LIKE '%2023' 
            THEN CASE
                -- If it's a short 3-letter month like 'Jan 2023' (Total length is 8 characters)
                WHEN LENGTH("RegistrationDate") = 8 THEN TO_DATE("RegistrationDate", 'Mon YYYY')
                -- Otherwise it's a full name like 'March 2023'
                ELSE TO_DATE("RegistrationDate", 'Month YYYY')
            END
            
        ELSE NULL
    END AS date

FROM cfk_beneficiaries;


                        -- ==========================================
                        -- 3. PROGRAM ACTIVITIES TABLE CLEANING
                       -- ==========================================
SELECT *
FROM cfk_program_activities;

 CREATE VIEW program_activities AS
-----cleaning program column
SELECT "ActivityID","Program","Activity Name","Attendance","Score/Grade",
    CASE 
        WHEN "BeneficiaryID" = 'CFK888' THEN 'unregistered'
        ELSE "BeneficiaryID"
        END AS BeneficiaryID,

        --------cleaning date
        CASE
         WHEN "Date"  LIKE '____-%' 
            THEN TO_DATE("Date", 'YYYY-MM-DD')
         WHEN "Date" LIKE '__-%' 
            THEN TO_DATE("Date", 'DD-MM-YYYY')
        WHEN "Date" LIKE '%/%/%' 
            THEN TO_DATE("Date", 'DD/MM/YYYY')

        WHEN "Date" LIKE '___ %'
            THEN TO_DATE("Date", 'Mon DD YYYY')

    -- 5. Long month text fallback: 'January 15 2024'
        WHEN "Date" LIKE 'Jan%' OR "Date" LIKE 'Feb%' OR "Date" LIKE 'Mar%' 
          OR "Date" LIKE 'Apr%' OR "Date" LIKE 'May%' OR "Date" LIKE 'Jun%' 
          OR "Date" LIKE 'Jul%' OR "Date" LIKE 'Aug%' OR "Date" LIKE 'Sep%' 
          OR "Date" LIKE 'Oct%' OR "Date" LIKE 'Nov%' OR "Date" LIKE 'Dec%'
            THEN TO_DATE("Date", 'Month DD YYYY')

        -- 6. Catch-all for corrupt text data ('N/A', blanks, typos)
        ELSE NULL 
    END AS date,

    --------clening Facilitator column 
TRIM(INITCAP("Facilitator")) AS facilitator ,

INITCAP("Completion Status") AS completion_status

   FROM cfk_program_activities;



    


            


