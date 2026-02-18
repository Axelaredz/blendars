# UI System Design Document
# Dracula / Cyberpunk sci-fi — справочник стилей и шейдеров

## 1. Цветовая палитра

**Путь:** `res://client/ui/theme/colors.gd`

## 8. Theme Generator

**Путь:** `res://client/ui/theme/theme_generator.gd`  
**Тип:** `@tool extends EditorScript`  
**Запуск:** Script Editor → File → Run (Ctrl+Shift+X)  
**Выход:** `res://client/ui/theme/dracula_theme.tres`

Генерирует стили для: Button, Label, PanelContainer, LineEdit, TabContainer, VScrollBar, CheckButton, OptionButton, HSeparator, PopupMenu.

**Ключевые вызовы:**
```gdscript
theme.set_stylebox("normal", "Button", btn_normal)
theme.set_color("font_color", "Button", fg)
theme.set_font_size("font_size", "Label", 16)
ResourceSaver.save(theme, "res://client/ui/theme/dracula_theme.tres")
```

---

## 9. Известные проблемы

| Проблема | Решение |
|---|---|
| `%NodeName` возвращает null | Правый клик на ноде → "Access as Unique Name" |
| Шрифт системный по умолчанию | Положить TTF в `res://client/ui/fonts/`, указать в Theme → Default Font |
| TabContainer добавляет скрытую TabBar | Имя дочерней ноды = название вкладки |
| HUD поверх 3D не работает | HUD должен быть CanvasLayer, не Control |
| `DColors` не найден | Убедиться что в `colors.gd` есть `class_name DColors` |
| Тема не применяется к дочерним сценам | Ставить `dracula_theme.tres` глобально в Project Settings → GUI → Theme |
| HSlider thumb не стилизуется | Нужна текстура 16×16, StyleBox не покрывает thumb |
