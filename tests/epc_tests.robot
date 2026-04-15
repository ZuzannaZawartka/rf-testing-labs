*** Settings ***
Library           RequestsLibrary
Suite Setup       Create Session    epc    http://epc-simulator:8000

*** Test Cases ***

Czy serwer dziala
    ${odpowiedz}=    GET On Session    epc    /
    Should Be Equal As Integers    ${odpowiedz.status_code}    200

Podlaczenie telefonu do sieci
    ${dane}=    Create Dictionary    ue_id=${5}
    ${odpowiedz}=    POST On Session    epc    /ues    json=${dane}
    Should Be Equal As Integers    ${odpowiedz.status_code}    200
    Should Be Equal    ${odpowiedz.json()}[status]    attached
    [Teardown]    POST On Session    epc    /reset