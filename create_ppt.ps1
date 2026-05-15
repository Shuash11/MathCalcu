Add-Type -AssemblyName Microsoft.Office.Interop.PowerPoint
Add-Type -AssemblyName Office

$ppt = New-Object -ComObject PowerPoint.Application
$ppt.Visible = [Microsoft.Office.Core.MsoTriState]::msoTrue
$presentation = $ppt.Presentations.Add()

$accent = 0x6C63FF
$darkBg = 0x1E1E2E
$cardBg = 0x2D2D44
$white = 0xFFFFFF
$gray = 0xB0B0B0
$lightBg = 0xF5F5FA

function Set-SlideBackground {
    param($slide, $color)
    $slide.Background.Fill.ForeColor.RGB = $color
    $slide.Background.Fill.Solid()
}

function Add-ModernTitle {
    param($pres, $title, $subtitle)

    $slide = $pres.Slides.Add(1, 1)
    Set-SlideBackground $slide $darkBg

    $accentBar = $slide.Shapes.AddShape(1, 50, 200, 80, 6)
    $accentBar.Fill.ForeColor.RGB = $accent
    $accentBar.Line.Visible = $false

    $titleBox = $slide.Shapes.AddTextbox(1, 50, 230, 850, 90)
    $titleBox.TextFrame.TextRange.Text = $title
    $titleBox.TextFrame.TextRange.Font.Size = 48
    $titleBox.TextFrame.TextRange.Font.Bold = $true
    $titleBox.TextFrame.TextRange.Font.Color.RGB = $white

    $subBox = $slide.Shapes.AddTextbox(1, 50, 340, 850, 50)
    $subBox.TextFrame.TextRange.Text = $subtitle
    $subBox.TextFrame.TextRange.Font.Size = 22
    $subBox.TextFrame.TextRange.Font.Color.RGB = $gray
}

function Add-ContentSlide {
    param($pres, $title, $items)

    $slide = $pres.Slides.Add($pres.Slides.Count + 1, 2)
    Set-SlideBackground $slide $lightBg

    $headerBg = $slide.Shapes.AddShape(1, 0, 0, 960, 100)
    $headerBg.Fill.ForeColor.RGB = $darkBg
    $headerBg.Line.Visible = $false

    $titleBox = $slide.Shapes.AddTextbox(1, 50, 30, 850, 50)
    $titleBox.TextFrame.TextRange.Text = $title
    $titleBox.TextFrame.TextRange.Font.Size = 28
    $titleBox.TextFrame.TextRange.Font.Bold = $true
    $titleBox.TextFrame.TextRange.Font.Color.RGB = $white

    $iconY = 130
    $col = 0
    $row = 0
    $cardWidth = 270
    $cardHeight = 140
    $gapX = 30
    $gapY = 25
    $startX = 50

    foreach ($item in $items) {
        $cardX = $startX + $col * ($cardWidth + $gapX)
        $cardY = $iconY + $row * ($cardHeight + $gapY)

        $card = $slide.Shapes.AddShape(1, $cardX, $cardY, $cardWidth, $cardHeight)
        $card.Fill.ForeColor.RGB = $white
        $card.Fill.Solid()
        $card.Line.ForeColor.RGB = 0xE0E0E0
        $card.Line.Weight = 1

        $iconCircle = $slide.Shapes.AddShape(9, $cardX + 20, $cardY + 20, 50, 50)
        $iconCircle.Fill.ForeColor.RGB = $accent
        $iconCircle.Line.Visible = $false

        $iconText = $slide.Shapes.AddTextbox(1, $cardX + 27, $cardY + 30, 36, 30)
        $iconText.TextFrame.TextRange.Text = $item.icon
        $iconText.TextFrame.TextRange.Font.Size = 16
        $iconText.TextFrame.TextRange.Font.Color.RGB = $white
        $iconText.TextFrame.TextRange.Font.Bold = $true

        $labelBox = $slide.Shapes.AddTextbox(1, $cardX + 80, $cardY + 25, 170, 25)
        $labelBox.TextFrame.TextRange.Text = $item.title
        $labelBox.TextFrame.TextRange.Font.Size = 14
        $labelBox.TextFrame.TextRange.Font.Bold = $true
        $labelBox.TextFrame.TextRange.Font.Color.RGB = $darkBg

        $descBox = $slide.Shapes.AddTextbox(1, $cardX + 80, $cardY + 50, 170, 70)
        $descBox.TextFrame.TextRange.Text = $item.desc
        $descBox.TextFrame.TextRange.Font.Size = 11
        $descBox.TextFrame.TextRange.Font.Color.RGB = 0x666666
        $descBox.TextFrame.WordWrap = $true

        $col++
        if ($col -ge 3) {
            $col = 0
            $row++
        }
    }
}

function Add-AgileSlide {
    param($pres)

    $slide = $pres.Slides.Add($pres.Slides.Count + 1, 2)
    Set-SlideBackground $slide $lightBg

    $headerBg = $slide.Shapes.AddShape(1, 0, 0, 960, 100)
    $headerBg.Fill.ForeColor.RGB = $darkBg
    $headerBg.Line.Visible = $false

    $titleBox = $slide.Shapes.AddTextbox(1, 50, 30, 850, 50)
    $titleBox.TextFrame.TextRange.Text = "Agile Development"
    $titleBox.TextFrame.TextRange.Font.Size = 28
    $titleBox.TextFrame.TextRange.Font.Bold = $true
    $titleBox.TextFrame.TextRange.Font.Color.RGB = $white

    $phases = @(
        @{ num = "01"; title = "Sprint 1"; desc = "Requirements & Planning" },
        @{ num = "02"; title = "Sprint 2-3"; desc = "Core Math Engine Development" },
        @{ num = "03"; title = "Sprint 4-5"; desc = "UI/UX Implementation" },
        @{ num = "04"; title = "Sprint 6"; desc = "Testing & Refinement" },
        @{ num = "05"; title = "Sprint 7"; desc = "Deployment & Documentation" }
    )

    $startX = 50
    $cardY = 150
    $cardW = 160
    $gap = 20

    for ($i = 0; $i -lt $phases.Count; $i++) {
        $p = $phases[$i]
        $x = $startX + $i * ($cardW + $gap)

        if ($i -lt $phases.Count - 1) {
            $connector = $slide.Shapes.AddShape(1, $x + $cardW, $cardY + 60, $gap + 5, 4)
            $connector.Fill.ForeColor.RGB = $accent
            $connector.Line.Visible = $false
        }

        $numCircle = $slide.Shapes.AddShape(9, $x + 50, $cardY, 60, 60)
        $numCircle.Fill.ForeColor.RGB = $accent
        $numCircle.Line.Visible = $false

        $numBox = $slide.Shapes.AddTextbox(1, $x + 50, $cardY + 15, 60, 35)
        $numBox.TextFrame.TextRange.Text = $p.num
        $numBox.TextFrame.TextRange.Font.Size = 20
        $numBox.TextFrame.TextRange.Font.Bold = $true
        $numBox.TextFrame.TextRange.Font.Color.RGB = $white
        $numBox.TextFrame.TextRange.ParagraphFormat.Alignment = 2

        $titleBox2 = $slide.Shapes.AddTextbox(1, $x, $cardY + 80, $cardW, 30)
        $titleBox2.TextFrame.TextRange.Text = $p.title
        $titleBox2.TextFrame.TextRange.Font.Size = 14
        $titleBox2.TextFrame.TextRange.Font.Bold = $true
        $titleBox2.TextFrame.TextRange.Font.Color.RGB = $darkBg
        $titleBox2.TextFrame.TextRange.ParagraphFormat.Alignment = 2

        $descBox2 = $slide.Shapes.AddTextbox(1, $x + 10, $cardY + 120, $cardW - 20, 150)
        $descBox2.TextFrame.TextRange.Text = $p.desc
        $descBox2.TextFrame.TextRange.Font.Size = 12
        $descBox2.TextFrame.TextRange.Font.Color.RGB = 0x666666
        $descBox2.TextFrame.TextRange.ParagraphFormat.Alignment = 2
        $descBox2.TextFrame.WordWrap = $true
    }
}

function Add-TwoColSlide {
    param($pres, $title, $leftTitle, $leftItems, $rightTitle, $rightItems)

    $slide = $pres.Slides.Add($pres.Slides.Count + 1, 2)
    Set-SlideBackground $slide $lightBg

    $headerBg = $slide.Shapes.AddShape(1, 0, 0, 960, 100)
    $headerBg.Fill.ForeColor.RGB = $darkBg
    $headerBg.Line.Visible = $false

    $titleBox = $slide.Shapes.AddTextbox(1, 50, 30, 850, 50)
    $titleBox.TextFrame.TextRange.Text = $title
    $titleBox.TextFrame.TextRange.Font.Size = 28
    $titleBox.TextFrame.TextRange.Font.Bold = $true
    $titleBox.TextFrame.TextRange.Font.Color.RGB = $white

    $colW = 400
    $leftX = 50
    $rightX = 510
    $contentY = 130

    $leftLabel = $slide.Shapes.AddTextbox(1, $leftX, $contentY, $colW, 35)
    $leftLabel.TextFrame.TextRange.Text = $leftTitle
    $leftLabel.TextFrame.TextRange.Font.Size = 18
    $leftLabel.TextFrame.TextRange.Font.Bold = $true
    $leftLabel.TextFrame.TextRange.Font.Color.RGB = $accent

    $leftUnderline = $slide.Shapes.AddShape(1, $leftX, $contentY + 38, 100, 4)
    $leftUnderline.Fill.ForeColor.RGB = $accent
    $leftUnderline.Line.Visible = $false

    $rightLabel = $slide.Shapes.AddTextbox(1, $rightX, $contentY, $colW, 35)
    $rightLabel.TextFrame.TextRange.Text = $rightTitle
    $rightLabel.TextFrame.TextRange.Font.Size = 18
    $rightLabel.TextFrame.TextRange.Font.Bold = $true
    $rightLabel.TextFrame.TextRange.Font.Color.RGB = $accent

    $rightUnderline = $slide.Shapes.AddShape(1, $rightX, $contentY + 38, 100, 4)
    $rightUnderline.Fill.ForeColor.RGB = $accent
    $rightUnderline.Line.Visible = $false

    $yPos = $contentY + 60
    foreach ($item in $leftItems) {
        $bullet = $slide.Shapes.AddShape(1, $leftX, $yPos + 5, 8, 8)
        $bullet.Fill.ForeColor.RGB = $accent
        $bullet.Line.Visible = $false

        $textBox = $slide.Shapes.AddTextbox(1, $leftX + 20, $yPos, $colW - 20, 40)
        $textBox.TextFrame.TextRange.Text = $item
        $textBox.TextFrame.TextRange.Font.Size = 14
        $textBox.TextFrame.TextRange.Font.Color.RGB = 0x444444
        $yPos += 40
    }

    $yPos = $contentY + 60
    foreach ($item in $rightItems) {
        $bullet = $slide.Shapes.AddShape(1, $rightX, $yPos + 5, 8, 8)
        $bullet.Fill.ForeColor.RGB = $accent
        $bullet.Line.Visible = $false

        $textBox = $slide.Shapes.AddTextbox(1, $rightX + 20, $yPos, $colW - 20, 40)
        $textBox.TextFrame.TextRange.Text = $item
        $textBox.TextFrame.TextRange.Font.Size = 14
        $textBox.TextFrame.TextRange.Font.Color.RGB = 0x444444
        $yPos += 40
    }
}

function Add-EndSlide {
    param($pres, $title, $subtitle)

    $slide = $pres.Slides.Add($pres.Slides.Count + 1, 1)
    Set-SlideBackground $slide $darkBg

    $titleBox = $slide.Shapes.AddTextbox(1, 50, 200, 860, 80)
    $titleBox.TextFrame.TextRange.Text = $title
    $titleBox.TextFrame.TextRange.Font.Size = 42
    $titleBox.TextFrame.TextRange.Font.Bold = $true
    $titleBox.TextFrame.TextRange.Font.Color.RGB = $white
    $titleBox.TextFrame.TextRange.ParagraphFormat.Alignment = 2

    $accentBar = $slide.Shapes.AddShape(1, 400, 300, 160, 5)
    $accentBar.Fill.ForeColor.RGB = $accent
    $accentBar.Line.Visible = $false

    $subBox = $slide.Shapes.AddTextbox(1, 50, 340, 860, 50)
    $subBox.TextFrame.TextRange.Text = $subtitle
    $subBox.TextFrame.TextRange.Font.Size = 20
    $subBox.TextFrame.TextRange.Font.Color.RGB = $gray
    $subBox.TextFrame.TextRange.ParagraphFormat.Alignment = 2
}

Add-ModernTitle $presentation "MathCalc" "AI-Powered Math Calculator for Students"

Add-ContentSlide $presentation "Features" @(
    @{ title = "Derivatives"; desc = "Symbolic differentiation with step-by-step solutions"; icon = "dx" },
    @{ title = "Limits"; desc = "Evaluating limits by substitution, factoring, LCD, conjugate"; icon = "lim" },
    @{ title = "Slope"; desc = "Find slope at a point using derivatives"; icon = "/" },
    @{ title = "Inequalities"; desc = "Linear, quadratic, rational, radical, absolute value"; icon = "<>" },
    @{ title = "Circles"; desc = "Center, radius, standard and general form"; icon = "O" },
    @{ title = "Distance & Midpoint"; desc = "With interactive graphing support"; icon = "-" }
)

Add-TwoColSlide $presentation "Architecture" "Frontend" @(
    "Flutter 3.10+",
    "Provider (State Management)",
    "go_router (Navigation)",
    "fl_chart (Graphing)",
    "flutter_math_fork (LaTeX)"
) "Core Libraries" @(
    "equations (Solver)",
    "math_expressions",
    "fn_express (Symbolic)",
    "Offline-first design",
    "Clean separation of concerns"
)

Add-AgileSlide $presentation

Add-TwoColSlide $presentation "Tech Stack" "Platform" @(
    "Android, iOS, Web, Desktop",
    "Flutter SDK 3.10+",
    "Dart SDK 3.0+",
    "GitHub Actions (CI/CD)"
) "Libraries" @(
    "flutter_math_fork",
    "provider & shared_preferences",
    "equations & math_expressions",
    "fn_express for symbolic math"
)

Add-EndSlide $presentation "Thank You" "Questions?"

$pptPath = "C:\ppt\MathCalc_Defense.pptx"
$presentation.SaveAs($pptPath)

while ($ppt.Presentations.Count -gt 0) {
    Start-Sleep -Milliseconds 100
}

$ppt.Quit()

[System.Runtime.Interopservices.Marshal]::ReleaseComObject([System.__ComObject]$presentation) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject([System.__ComObject]$ppt) | Out-Null
[GC]::Collect()
[GC]::WaitForPendingFinalizers()

Write-Host "Saved to: $pptPath"