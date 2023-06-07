*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.FileSystem


*** Variables ***
${pdf_folder}=      ${OUTPUT_DIR}${/}receipts${/}


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Set up directories
    Open the robot order website
    Download the orders file, read it as a table, and return the result
    Loop the orders
    Create ZIP package from PDF files
    Close the browser


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the orders file, read it as a table, and return the result
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Loop the orders
    ${orders}=    Read table from CSV    ${CURDIR}${/}orders.csv    header=True
    FOR    ${row}    IN    @{orders}
        Close the Pop-Up
        Wait Until Keyword Succeeds    10x    2s    Fill the form    ${row}
    END

Close the Pop-Up
    Click Button    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Fill the form
    [Arguments]    ${orders}
    Select From List By Value    head    ${orders}[Head]
    Select Radio Button    body    ${orders}[Body]
    Input Text    css=.form-control    ${orders}[Legs]
    Input Text    address    ${orders}[Address]
    Click Button    preview
    Wait Until Element Is Visible    css:#robot-preview-image
    Sleep    3s
    ${robotpic}=    Screenshot
    ...    xpath://*[@id="robot-preview-image"]
    ...    ${OUTPUT_DIR}${/}robot_${orders}[Order number].png
    Click Button    order
    Wait Until Element Is Visible    id:receipt
    ${order_receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_receipt}    ${pdf_folder}receipt_${orders}[Order number].pdf
    Open Pdf    ${pdf_folder}receipt_${orders}[Order number].pdf
    ${file}=    Create List
    ...    ${pdf_folder}receipt_${orders}[Order number].pdf
    ...    ${robotpic}
    Add Files To pdf    ${file}    ${pdf_folder}receipt_${orders}[Order number].pdf
    Click Button    id:order-another

Set up directories
    Create Directory    ${pdf_folder}

Create ZIP package from PDF files
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/Receipts.zip
    Archive Folder With Zip
    ...    ${pdf_folder}
    ...    ${zip_file_name}

Close the browser
    Close Browser
