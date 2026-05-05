#Requires AutoHotkey v2.0

SetCapsLockState "AlwaysOff"

; Alt+Shift+F1 : Lance Unity sur Lootopia + Rider avec la solution + Chrome
!+F1:: {
    Run('"C:\Program Files\Unity\Hub\Editor\6000.3.6f1\Editor\Unity.exe" -projectPath "C:\Code\Unity\Lootopia"')
    Run('"C:\Program Files\JetBrains\JetBrains Rider 2024.1.2\bin\rider64.exe" "C:\Code\Unity\Lootopia\Lootopia.sln"')
    Run('"C:\Program Files\Google\Chrome\Application\chrome.exe"')
}

!+Escape::Run("chrome")
!+F2::Run("explorer.exe")
!+F3::Run("code")
!+F4::Run("cmd")