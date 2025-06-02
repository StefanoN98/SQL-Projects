This function based on how zip code in Brazil works associate to each zip_code the related state, checking on the first 3 character
This rule will guarantee that the state for each zip_code is consistent and correct

```sql
CREATE FUNCTION dbo.GetStatoFromZipPrefix (@prefixStr VARCHAR(3))
RETURNS VARCHAR(2)
AS
BEGIN
    DECLARE @prefix INT

    IF ISNUMERIC(@prefixStr) = 1
        SET @prefix = CAST(@prefixStr AS INT)
    ELSE
        RETURN NULL

    IF @prefix BETWEEN 1 AND 9 RETURN 'SP'
    IF @prefix BETWEEN 10 AND 99 RETURN 'SP'
    IF @prefix BETWEEN 100 AND 109 RETURN 'SP'
    IF @prefix BETWEEN 110 AND 199 RETURN 'SP'
    IF @prefix BETWEEN 200 AND 289 RETURN 'RJ'
    IF @prefix BETWEEN 290 AND 299 RETURN 'ES'
    IF @prefix BETWEEN 300 AND 399 RETURN 'MG'
    IF @prefix BETWEEN 400 AND 489 RETURN 'BA'
    IF @prefix BETWEEN 490 AND 499 RETURN 'SE'
    IF @prefix BETWEEN 500 AND 569 RETURN 'PE'
    IF @prefix BETWEEN 570 AND 579 RETURN 'AL'
    IF @prefix BETWEEN 580 AND 589 RETURN 'PB'
    IF @prefix BETWEEN 590 AND 599 RETURN 'RN'
    IF @prefix BETWEEN 600 AND 639 RETURN 'CE'
    IF @prefix BETWEEN 640 AND 649 RETURN 'PI'
    IF @prefix BETWEEN 650 AND 659 RETURN 'MA'
    IF @prefix BETWEEN 660 AND 688 RETURN 'PA'
    IF @prefix = 689 RETURN 'AP'
    IF @prefix BETWEEN 690 AND 692 RETURN 'AM'
    IF @prefix = 693 RETURN 'RR'
    IF @prefix BETWEEN 694 AND 698 RETURN 'AM'
    IF @prefix = 699 RETURN 'AC'
    IF @prefix BETWEEN 700 AND 727 RETURN 'DF'
    IF @prefix BETWEEN 728 AND 729 RETURN 'GO'
    IF @prefix BETWEEN 730 AND 736 RETURN 'DF'
    IF @prefix BETWEEN 737 AND 767 RETURN 'GO'
    IF @prefix BETWEEN 768 AND 769 RETURN 'RO'
    IF @prefix BETWEEN 770 AND 779 RETURN 'TO'
    IF @prefix BETWEEN 780 AND 788 RETURN 'MT'
    IF @prefix = 789 RETURN 'MT'
    IF @prefix BETWEEN 790 AND 799 RETURN 'MS'
    IF @prefix BETWEEN 800 AND 879 RETURN 'PR'
    IF @prefix BETWEEN 880 AND 899 RETURN 'SC'
    IF @prefix BETWEEN 900 AND 999 RETURN 'RS'

    RETURN NULL
END
```
