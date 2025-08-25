#Esegui questa cella una sola volta all'inizio del notebook
#Run this cell only one-time at the start of your notebook
import altair as alt

# Vaporwave_modified color palette
background: str = "#000000"  # BLACK
gridColor: str = "#4A7295"  # lighter blue-grey
textColor: str = "#C7CCC9"  # light grey
#markColor: str = "#87CEEB"  # CELESTE
#markColor: str = "#6495ED"  # AZZURRO
#markColor: str = "#0000ff"
markColor: str ="#ff00ff"
#markColor: str = "#33d4ff"  # KINDOFBLUE
#markColor: str = "#B3FF11"  # VERDE MELA
defaultFont: str = 'IBM Plex Sans,system-ui,-apple-system,BlinkMacSystemFont,".sfnstext-regular",sans-serif'
condensedFont: str = 'IBM Plex Sans Condensed, system-ui, -apple-system, BlinkMacSystemFont, ".SFNSText-Regular", sans-serif'
fontWeight = 400


# Vaporwave palette
# line_colors = [
#     "#33a8c7ff",  
#     "#52e3e1ff",  
#     "#a0e426ff",  
#     "#fdf148ff",  
#     "#ffab00ff",  
#     "#f77976ff",  
#     "#f050aeff",  
#     "#d883ffff",  
#     "#9336fdff",  
# ]

# line_colors = [
#     "#3366FF",  
#     "#33CCFF",  
#     "#44E602",  
#     "#FFFF00",  
#     "#FF9900",  
#     "#f77976ff",  
#     "#d01c8b",  
#     "#CC66FF",  
#     "#9900CC",
# ]

line_colors = [
    "#0000FF",
    "#FF6600FF",  
    "#44E602",  
    "#ff00ff",
    "#FFFF00",
    "#9900CC",
    "#33CCFF",
    "#f77976ff",
    "#CC66FF"
]

# NON USARE PIÙ IL DECORATORE QUI
def altair_vaporwave_theme() -> dict: # La type hint corretta è dict, non alt.theme.ThemeConfig
    return {
        'config': {
            'view': {
                'continuousWidth': 400,
                'continuousHeight': 300,
                'stroke':gridColor,
                'strokeWidth': 1,
            },
            'background': background,
            'mark': {'color': markColor},
            'arc': {'fill': markColor},
            'area': {
                'fill': markColor,
                'line': True,
                'fillOpacity': 0.1
            },
            'line': {
                'stroke': markColor,
                'strokeWidth': 2
            },
            'path': {'stroke': markColor},
            'rect': {'fill': markColor},
            'shape': {'stroke': markColor},
            'symbol': {'fill': markColor},

            'title': {
                'color': textColor,
                'anchor': 'start',
                'dy': -15,
                'fontSize': 16,
                'font': defaultFont,
                'fontWeight': 600,
            },

            'axisBand': {
                'grid': False,
            },
            'axis': {
                # Axis labels
                'labelColor': textColor,
                'labelFontSize': 16,
                'labelFont': condensedFont,
                'labelFontWeight': fontWeight,
                # Axis titles
                'titleColor': textColor,
                'titleFontWeight': 600,
                'titleFontSize': 16,

                # MISC
                'grid': True,
                'gridColor': gridColor,
                'labelAngle': 0,
                'domainColor': None,
                'tickColor': None,
                'labelPadding': 2,
                'tickSize': 6,
                'tickWidth': 0.5,
                # Make grid appear above marks (important for lines under grid)
                'gridOpacity': 1,
                'gridZ': 1
            },

            'axisX': {
                'gridDash': [6, 3],
                'gridWidth': 0.35,
                'gridColor': gridColor,
                'labelAngle': 0
            },

            'axisY': {
                'gridDash': [6, 3],
                'gridWidth': 0.35,
                'gridColor': gridColor,
            },

            # This controls the layer order
            'layer': {
                'grid': 1,  # Higher z-index for grid (on top)
                'mark': 0  # Lower z-index for marks (below)
            },

            'legend': {
                'labelFontSize': 11,
                'padding': 1,
                'symbolType': 'square',
                'labelColor': textColor,
                'titleColor': textColor
            },
            'style': {
                'guide-label': {
                    'font': defaultFont,
                    'fill': textColor,
                    'fontWeight': fontWeight,
                },
                'guide-title': {
                    'font': defaultFont,
                    'fill': textColor,
                    'fontWeight': fontWeight,
                },
            },
            'range': {
                'category': line_colors,
            },
        }
    }

alt.themes.register('altair_vaporwave_theme', altair_vaporwave_theme)

alt.themes.enable('altair_vaporwave_theme')

#print("Tema 'altair_vaporwave_theme' registrato e attivato con successo!")