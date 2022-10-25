*** Settings ***
Library                 ../libraries/custom.py
Library                 QWeb

*** Keywords ***
Home
    [Documentation]     Set the application state to the shop home page.
    Print Message       Going Home
    GoTo                ${base_url}
