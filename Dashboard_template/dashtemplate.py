import pandas as pd
import plotly.express as px
import dash
from dash import html
from dash import dcc
from dash.dependencies import Input, Output
import dash_bootstrap_components as dbc

app = dash.Dash(external_stylesheets=[dbc.themes.BOOTSTRAP])

content1 = dbc.Row([
    dbc.Col([
        html.H3("Placeholder for inputs"),
        html.H3("Placeholder for outputs")
    ], width = 5),
    dbc.Col([
        html.H3("Placeholder for Graph"),
    ])
]
)

content2 = dbc.Row([
    dbc.Col([
        html.H3("Placeholder for inputs"),
        html.H3("Placeholder for outputs")
    ], width = 5),
    dbc.Col([
        "Placeholder for graph"
    ])
]
)

tabs = dbc.Tabs([
    dbc.Tab([
        content1
    ], label = "Tab 1"), 
    dbc.Tab([
        content2
    ], label = "Tab 2")
])


app.layout = html.Div(
    children=[
        html.H1("Title"),
        tabs
    ]
)


if __name__ == '__main__':
    app.run_server(debug=True, port = 8055)