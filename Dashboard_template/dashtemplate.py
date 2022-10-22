import pandas as pd
import plotly.express as px
import dash
from dash import html
from dash import dcc
from dash.dependencies import Input, Output
import dash_bootstrap_components as dbc
import plotly.graph_objects as go
from plotly.subplots import make_subplots

data = pd.read_excel("outputdata.xlsx", header=1)
data.head()


###TAB 1 GRAPHS


### TAB 2-1 GRAPHS
def create_plot_crowd(time="afternoon", density="medium"):
    df = data[data["time_of_day"] == time]
    df = df[df["population_density"] == density]

    crowd_heat_df = df[["number_of_lanes", "ratio", "avg_crowd_size"]]
    crowd_lanes = df[["number_of_lanes", "avg_crowd_size"]].groupby("number_of_lanes").mean()
    crowd_ratio = df[["ratio", "avg_crowd_size"]].groupby("ratio").mean()

    fig = make_subplots(
        rows=2, cols=2,
        column_widths=[0.5, 0.5],
        row_heights=[0.5, 0.5],
        specs=[[{"type": "heatmap", "rowspan": 2}, {"type": "bar"}],
           [None, {"type": "bar"}]])
    
    fig.add_trace(
    go.Heatmap(x = crowd_heat_df["number_of_lanes"],
        y =  crowd_heat_df["ratio"],
        z =  crowd_heat_df["avg_crowd_size"]
        ),
    row=1, col=1,
    )

    fig.add_trace(
    go.Bar(x = crowd_lanes.index,
        y = crowd_lanes["avg_crowd_size"]
        ),
    row=1, col=2,
    )

    fig.add_trace(
    go.Bar(x = crowd_ratio.index,
        y = crowd_ratio["avg_crowd_size"]
        ),
    row=2, col=2,
    )

    fig.update_xaxes(title_text="Number of Lanes", row=1, col=1)
    fig.update_xaxes(title_text="Number of Lanes", row=1, col=2)
    fig.update_xaxes(title_text="Green-Red Ratio", row=2, col=2)

    fig.update_yaxes(title_text="Green-Red Ratio", row=1, col=1)
    fig.update_yaxes(title_text="Average Crowd Size", row=1, col=2)
    fig.update_yaxes(title_text="Average Crowd Size", row=2, col=2)

    return fig

### TAB 2-2 GRAPHS


### TAB 2-3 GRAPHS



app = dash.Dash(external_stylesheets=[dbc.themes.BOOTSTRAP, 'https://codepen.io/chriddyp/pen/bWLwgP.css'])

#### TAB 1 CONTENT
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

### TAB 2 CONTENT
content2 = dcc.Tabs(id="graph-tabs", children=[
            dcc.Tab([dcc.Graph(id = "graph_crowd", figure=create_plot_crowd())],label='Pedestrians'),
            dcc.Tab([dcc.Graph(id = "graph_crowd2", figure=create_plot_crowd())],label='Cars'),
            dcc.Tab(label='Compare'),
        ],  vertical=True, parent_style={'float': 'left'})



### OVERALL

## SIDEBAR

sidebar = html.Div([
    html.H6("Speed Limit"),
    dcc.Slider(id = "speed-limit", min = 0, max = 2, step = 0.1, value=1, marks=None,
        tooltip={"placement": "bottom", "always_visible": True}),
    html.H6("Number of Cars"),
    dcc.Slider(id = "number-of-cars", min = 0, max = 70, step = 1, value=10, marks=None,
        tooltip={"placement": "bottom", "always_visible": True}),
    html.H6("Number of Pedestrians"),
    dcc.Slider(id = "number-of-pedestrians", min = 0, max = 60, step = 1, value=10, marks=None,
        tooltip={"placement": "bottom", "always_visible": True}),
    html.H6("Max patience"),
    dcc.Slider(id = "max-patience", min = 0, max = 50, step = 1, value=10, marks=None,
        tooltip={"placement": "bottom", "always_visible": True}),
    html.H6("Time to cross"),
    dcc.Slider(id = "time-to-cross", min = 0, max = 40, step = 1, value=10, marks=None,
        tooltip={"placement": "bottom", "always_visible": True}),
    html.H6("Acceleration"),
    dcc.Slider(id = "acceleration", min = 0, max = 0.01, step = 0.001, value=0.005, marks=None,
        tooltip={"placement": "bottom", "always_visible": True}),
    html.H6("Deceleration"),
    dcc.Slider(id = "deceleration", min = 0, max = 0.1, step = 0.01, value=0.05, marks=None,
        tooltip={"placement": "bottom", "always_visible": True}),
    html.H6("Basic Politeness"),
    dcc.Slider(id = "basic-politeness", min = 0, max = 100, step = 1, value= 10, marks=None,
        tooltip={"placement": "bottom", "always_visible": True})
])

### TABS

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
        dbc.Row([ 
            dbc.Col([
                sidebar
            ], width = 2),
            dbc.Col([
                tabs
            ], width = 10)
        ])
    ],
    style={"margin-left": "20px", "margin-right": "20px", "margin-top": "15px"}
)


#####CALLBACKS


if __name__ == '__main__':
    app.run_server(debug=True, port = 8055)