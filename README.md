```
local TobaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Legitxwx/Toba/refs/heads/main/Library.lua"))((
```
```
local win = TobaUI:CreateWindow({
    Title = "Ultimate Max UI",
    Author = "Ivan",
    Version = "5.0"
})
```
```
local mainTab = win:CreateTab("Main")
```
```
mainTab:Section("Core Settings")
```
```
mainTab:Paragraph({
    Title = "Welcome!",
    Desc = "TobaUI Ultimate Max Edition fully loaded!"
})
```
```
mainTab:Button({
    Title = "Press Me",
    Callback = function()
        TobaUI:Notify("Button Pressed", "You clicked the main button", 2)
    end
})
```
```
mainTab:Toggle({
    Title = "Enable Feature",
    Default = true,
    Callback = function(state)
        print("Toggle:", state)
    end
})
```
```
mainTab:Slider({
    Title = "Volume",
    Default = 50,
    Max = 100,
    Callback = function(val)
        print("Slider:", val)
    end
})
```
```
mainTab:Dropdown({
    Title = "Select Mode",
    Items = {"Easy", "Normal", "Hard"},
    Callback = function(val)
        print("Dropdown Selected:", val)
    end
})
```

# -- HOOK EXAMPLE
```
TobaUI:hookme("ButtonClicked", function(name)
    print("Button clicked hook:", name)
end)
```
