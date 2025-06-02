# 🇧🇷 Mapping Brazilian Zip Code Prefixes to States 📍

To associate Brazilian states with zip codes (CEP), we use a **standard mapping** based on the prefix of the zip code.  
This mapping links the **first digit (or first few digits)** of the CEP to the corresponding state, as shown in the table below:

| Prefix CEP (Xxxxx) | State | State Name             |
|--------------------|-------|------------------------|
| 0xxxx              | SP    | São Paulo              |
| 1xxxx              | SP    | São Paulo (rest of state)|
| 2xxxx              | RJ    | Rio de Janeiro         |
|                    | ES    | Espírito Santo         |
| 3xxxx              | MG    | Minas Gerais           |
| 4xxxx              | BA    | Bahia                  |
|                    | SE    | Sergipe                |
| 5xxxx              | PE    | Pernambuco             |
|                    | AL    | Alagoas                |
|                    | PB    | Paraíba                |
|                    | RN    | Rio Grande do Norte    |
| 6xxxx              | CE    | Ceará                  |
|                    | PI    | Piauí                  |
|                    | MA    | Maranhão               |
|                    | PA    | Pará                   |
|                    | AP    | Amapá                  |
|                    | AM    | Amazonas               |
|                    | RR    | Roraima                |
|                    | AC    | Acre                   |
| 7xxxx              | DF    | Distrito Federal       |
|                    | GO    | Goiás                  |
|                    | TO    | Tocantins              |
|                    | RO    | Rondônia               |
|                    | MT    | Mato Grosso            |
|                    | MS    | Mato Grosso do Sul     |
| 8xxxx              | PR    | Paraná                 |
|                    | SC    | Santa Catarina         |
| 9xxxx              | RS    | Rio Grande do Sul      |

---

## ⚙️ Implementation Detail

We implement a function that **extracts the first three digits** of a Brazilian zip code (CEP) and returns the associated state based on this prefix.  
This method guarantees that the assigned state is **consistent and accurate** according to the official postal code structure.

---

### 📥 Parameters

`@prefixStr (VARCHAR(3))`:  
This input parameter represents the **first three characters** of the Brazilian zip code (CEP).  
The function expects this to be a **string containing digits only** (e.g., `'010'`, `'290'`, `'700'`).

---
### 🎯 Purpose

The function was created to **ensure consistency** in our datasets, as we often encountered zip codes associated with multiple states or incorrect states.  
By standardizing state assignment based on official zip code prefixes, we **guarantee consistency and correctness** whenever we add or integrate new data.

---

### 🧠 Function Logic

1. **Input Validation:**  
   The function first checks if the input string `@prefixStr` is numeric using the `ISNUMERIC()` function.  
   If the input is **not numeric**, the function returns `NULL` indicating an invalid or unrecognized prefix.

2. **Conversion:**  
   If the input is numeric, the function casts the string to an integer `@prefix` to facilitate numerical comparison.

3. **Prefix Range Mapping:**  
   The function compares the numeric prefix against predefined numeric ranges that correspond to different Brazilian states.  
   Each range represents the first three digits of the zip code prefixes allocated to a particular state.

   For example:  
   - Prefixes between **1 and 199** correspond to São Paulo (`SP`).  
   - Prefixes between **200 and 289** correspond to Rio de Janeiro (`RJ`).  
   - And so on, for all states.

4. **Return Value:**  
   When the prefix falls within a specific range, the function returns the **two-letter abbreviation** of the corresponding state (e.g., `'SP'`, `'RJ'`, `'MG'`).

5. **Fallback:**  
   If the prefix does not match any known range, the function returns `NULL`, indicating **no valid state** was found for that prefix.

---

```sql
CREATE FUNCTION dbo.GetStatoFromZipPrefix (@prefixStr VARCHAR(3))
RETURNS VARCHAR(2)
AS
BEGIN
    DECLARE @prefix INT;

    IF ISNUMERIC(@prefixStr) = 1
        SET @prefix = CAST(@prefixStr AS INT);
    ELSE
        RETURN NULL;

    IF @prefix BETWEEN 1 AND 9 RETURN 'SP';
    IF @prefix BETWEEN 10 AND 99 RETURN 'SP';
    IF @prefix BETWEEN 100 AND 109 RETURN 'SP';
    IF @prefix BETWEEN 110 AND 199 RETURN 'SP';
    IF @prefix BETWEEN 200 AND 289 RETURN 'RJ';
    IF @prefix BETWEEN 290 AND 299 RETURN 'ES';
    IF @prefix BETWEEN 300 AND 399 RETURN 'MG';
    IF @prefix BETWEEN 400 AND 489 RETURN 'BA';
    IF @prefix BETWEEN 490 AND 499 RETURN 'SE';
    IF @prefix BETWEEN 500 AND 569 RETURN 'PE';
    IF @prefix BETWEEN 570 AND 579 RETURN 'AL';
    IF @prefix BETWEEN 580 AND 589 RETURN 'PB';
    IF @prefix BETWEEN 590 AND 599 RETURN 'RN';
    IF @prefix BETWEEN 600 AND 639 RETURN 'CE';
    IF @prefix BETWEEN 640 AND 649 RETURN 'PI';
    IF @prefix BETWEEN 650 AND 659 RETURN 'MA';
    IF @prefix BETWEEN 660 AND 688 RETURN 'PA';
    IF @prefix = 689 RETURN 'AP';
    IF @prefix BETWEEN 690 AND 692 RETURN 'AM';
    IF @prefix = 693 RETURN 'RR';
    IF @prefix BETWEEN 694 AND 698 RETURN 'AM';
    IF @prefix = 699 RETURN 'AC';
    IF @prefix BETWEEN 700 AND 727 RETURN 'DF';
    IF @prefix BETWEEN 728 AND 729 RETURN 'GO';
    IF @prefix BETWEEN 730 AND 736 RETURN 'DF';
    IF @prefix BETWEEN 737 AND 767 RETURN 'GO';
    IF @prefix BETWEEN 768 AND 769 RETURN 'RO';
    IF @prefix BETWEEN 770 AND 779 RETURN 'TO';
    IF @prefix BETWEEN 780 AND 788 RETURN 'MT';
    IF @prefix = 789 RETURN 'MT';
    IF @prefix BETWEEN 790 AND 799 RETURN 'MS';
    IF @prefix BETWEEN 800 AND 879 RETURN 'PR';
    IF @prefix BETWEEN 880 AND 899 RETURN 'SC';
    IF @prefix BETWEEN 900 AND 999 RETURN 'RS';

    RETURN NULL;
END
