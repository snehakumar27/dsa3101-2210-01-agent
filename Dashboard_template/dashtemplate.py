import pandas as pd
import plotly.express as px
import dash
import numpy as np
from dash import html
from dash import dcc
from dash.dependencies import Input, Output
import dash_bootstrap_components as dbc
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import dash_daq as daq

data = pd.read_excel("permsnewdata.xlsx", header=0)
data.head()

#needs two num_lanes input
default = {"num_cars": 10, "patience":0.6, "num_pedestrians":10}

def get_data(num_cars, num_ped, patience):
    data1 = data[data['num_cars'] == num_cars]
    data2 = data1[data1['num_pedestrians'] == num_ped]
    datause = data2[data2['patience'] == patience]
    return datause



###TAB 1 GRAPHS


### TAB 2-1 GRAPHS
def create_plot_ped(num_cars = 10, num_ped = 10, patience=0.6):
    data = get_data(num_cars, num_ped, patience)
    
    crowd_heat_df = data[["mean-speed-ped", "car-lights-interval", "pedestrian-lights-interval"]]
    crowd_car_interval = data[["car-lights-interval", "mean-speed-ped"]].groupby("car-lights-interval").mean()
    crowd_ped_interval = data[["pedestrian-lights-interval", "mean-speed-ped"]].groupby("pedestrian-lights-interval").mean()

    
    fig = make_subplots(
        rows=3, cols=1,
        vertical_spacing=0.15,
        subplot_titles=("Pedestrian light interval VS average crowd size",
                        "Car light interval VS average crowd size",
                        "Heatmap between traffic light interval and average crowd size"),
        row_heights=[0.6,0.6,0.95])
        

    fig.add_trace(
    go.Heatmap(x = crowd_heat_df["car-lights-interval"],
        y =  crowd_heat_df["pedestrian-lights-interval"],
        z =  crowd_heat_df["mean-speed-ped"],
               colorbar=dict(y=0.16,len=.3)
        ),
    row=3, col=1,
    )

    fig.add_trace(go.Line(x = crowd_car_interval.index,
                      y = crowd_car_interval["avg_crowd_size"]),
    row=2, col=1,
    )

    
    fig.add_trace(go.Line(x = crowd_ped_interval.index,
        y = crowd_ped_interval["avg_crowd_size"]),
    row=1, col=1,
    )


    fig.update_xaxes(title_text="Pedestrian light interval", row=1, col=1)
    fig.update_xaxes(title_text="Car light interval", row=2, col=1)
    fig.update_xaxes(title_text="Car light interval", row=3, col=1)

    fig.update_yaxes(title_text="Average Crowd Size", row=1, col=1)
    fig.update_yaxes(title_text="Average Crowd Size", row=2, col=1)
    fig.update_yaxes(title_text="Pedestrian light interval", row=3, col=1)
    fig.update_layout(
        height = 800,
        width = 800,
        #legend_tracegroupgap = 180,
        showlegend=False
    )


    return fig

### TAB 2-2 GRAPHS
def create_plot_car(num_cars = 10, num_ped = 10, patience=0.6):
    data = get_data(num_cars, num_ped, patience)
    
    con_heat_df = data[["pedestrian-lights-interval", "car_lights_interval", "mean-speed-car"]]
    con_car_interval = data[["car-lights-interval", "mean-speed-ped"]].groupby("car-lights-interval").mean()
    con_ped_interval = data[["pedestrian-lights-interval", "mean-speed-ped"]].groupby("pedestrian-lights-interval").mean()
    
    fig = make_subplots(
        rows=3, cols=1,
        vertical_spacing=0.08,
        subplot_titles=("Pedestrian light interval VS Average waiting time",
            "Car light interval VS Average waiting time",
            "Heatmap on Average speed of the car"),
        row_heights=[0.6,0.6,0.95])
    
    fig.add_trace(go.Line(x = con_ped_interval.index,
                      y = con_ped_interval["avg_crowd_size"]),
    row=1, col=1,
    )
    
    fig.add_trace(go.Line(x = con_car_interval.index,
                      y = con_car_interval["avg_crowd_size"]),
    row=2, col=1,
    )
    

    fig.add_trace(
    go.Heatmap(x = con_heat_df["num_lanes"],
        y =  con_heat_df["light_interval"],
        z =  con_heat_df["avg_speed_cars"],
        colorbar=dict(y=0.45,len=0.25)),
    row=3, col=1,
    )



    fig.update_xaxes(title_text="Pedestrian light interval", row=1, col=1)
    fig.update_xaxes(title_text="Car light interval", row=2, col=1)
    fig.update_xaxes(title_text="Car light interval", row=3, col=1)
    
    fig.update_yaxes(title_text="Average Waiting Time", row=1, col=1)
    fig.update_yaxes(title_text="Average Waiting Time", row=2, col=1)
    fig.update_yaxes(title_text="Pedestrian light interval", row=3, col=1)
    fig.update_layout(
        height = 800,
        width = 800,
        showlegend=False
    )

    return fig


### TAB 2-3 GRAPHS


app = dash.Dash(external_stylesheets=[dbc.themes.BOOTSTRAP, 'https://codepen.io/chriddyp/pen/bWLwgP.css'])

#### TAB 1 CONTENT
content1 = dbc.Row([
    dbc.Col([
        html.H6("Number of Lanes"),
        html.Div(
            [
                dbc.Button("Decrease Lane", id = "decrease_lane", color = "danger", className = "me-1", n_clicks = 0),
                html.Span(id="number-of-lanes", style={"verticalAlign": "middle"}),
                dbc.Button("Increase Line", id = "increase_lane", color = "success", className = "me-1", n_clicks = 0),
            ]
        ),
        html.H6("Green to Red Ratio"),
        html.Div(
            [
                dbc.Button("-", id = "decrease_light", color = "danger", className = "me-1", n_clicks = 0),
                html.Span(id="light-interval", style={"verticalAlign": "middle"}),
                dbc.Button("+", id = "increase_light", color = "success", className = "me-1", n_clicks = 0),
            ]
        ),
    ], width = 5),
    dbc.Col([
        html.H6("Average Waiting Time"),
        html.Div(
            [
                daq.Gauge(
                    showCurrentValue=True,
                    color={"gradient":True, 
                            "ranges":{"green":[0,60], "yellow":[60,80],"red":[80,100],"purple": [100, 120]}},
                    scale={'start': 0, 'interval': 10, 'labelInterval': 3},
                    units="seconds",
                    value=40,
                    label='Avg Waiting Time (Cars)',
                    max=120,
                    min=0,
                    size = 200
                ),
                daq.Gauge(
                    showCurrentValue=True,
                    color={"gradient":True, 
                            "ranges":{"green":[0,60], "yellow":[60,80],"red":[80,100],"purple": [100, 120]}},
                    scale={'start': 0, 'interval': 10, 'labelInterval': 3},
                    units="seconds",
                    value=75,
                    label='Avg Waiting Time (Pedestrians)',
                    max=120,
                    min=0,
                    size = 200
                ),
            ]
        ),
    ])
]
)

### TAB 2 CONTENT
content2 = dcc.Tabs(id="graph-tabs", children=[
            dcc.Tab([dcc.Graph(id = "graph_crowd", figure=create_plot_crowd())],label='Pedestrians'),
            dcc.Tab([dcc.Graph(id = "graph_car", figure=create_plot_car())],label='Cars'),
            dcc.Tab(label='Compare'),
        ],  vertical=True, parent_style={'float': 'left'})



### OVERALL

## SIDEBAR

sidebar = html.Div([
    html.H6("Number of Cars"),
    dcc.Slider(id = "number-of-cars", min = 0, max = 50, step = 5, value=10, 
        tooltip={"placement": "bottom", "always_visible": True}),
    html.H6("Number of Pedestrians"),
    dcc.Slider(id = "number-of-pedestrians", min = 0, max = 50, step = 5, value=10, 
        tooltip={"placement": "bottom", "always_visible": True}),
    html.H6("Max patience"),
    dcc.Slider(id = "max-patience", min = 0, max = 1, step = 0.2, value=1, 
        tooltip={"placement": "bottom", "always_visible": True}),
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
        html.H1("Junction Simulation"),
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
@app.callback(
    Output("number-of-lanes", "children"), [Input("increase_lane", "n_clicks"), Input("decrease_lane", "n_clicks")]
)
def on_button_click(n, m):
    return f"{n - m} lanes"

@app.callback(
    Output("light-interval", "children"), [Input("increase_light", "n_clicks"), Input("decrease_light", "n_clicks")]
)
def on_button_click(n, m):
    return format((n - m) / 2, '.1f')

if __name__ == '__main__':
    app.run_server(debug=True, port = 8055)
