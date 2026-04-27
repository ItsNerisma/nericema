#Requires AutoHotkey v2.0

; Ctrl+F1 : Lance Unity sur Lootopia + Rider avec la solution + Chrome
^F1:: {
    Run('"C:\Program Files\Unity\Hub\Editor\6000.3.6f1\Editor\Unity.exe" -projectPath "C:\Code\Unity\Lootopia"')
    Run('"C:\Program Files\JetBrains\JetBrains Rider 2024.1.2\bin\rider64.exe" "C:\Code\Unity\Lootopia\Lootopia.sln"')
    Run('"C:\Program Files\Google\Chrome\Application\chrome.exe"')
}

; Ctrl+F2 : Ouvre un nouvel explorateur de fichiers
^F2::Run("explorer.exe")
^F3::Run("code")
^F4::Run("chrome")
^Escape::Run("cmd")