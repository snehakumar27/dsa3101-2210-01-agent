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

default = {"num_cars": 10, "patience":0.6, "num_pedestrians":10}

def get_data(num_cars, num_ped, patience):
    data1 = data[data['num_cars'] == num_cars]
    data2 = data1[data1['num_pedestrians'] == num_ped]
    datause = data2[data2['patience'] == patience]
    return datause



###TAB 1 GRAPHS


### TAB 2-1 GRAPHS
def create_plot_crowd(num_cars = 10, num_ped = 10, patience=0.6):
    data = get_data(num_cars, num_ped, patience)
    
    line1 = data[data['num_lanes'] ==1]
    line2 = data[data['num_lanes'] ==2]
    line3 = data[data['num_lanes'] ==3]
    line4 = data[data['num_lanes'] ==4]

    crowd_heat_df = data[["num_lanes", "light_interval", "avg_crowd_size"]]
    crowd_lanes = data[["num_lanes", "avg_crowd_size"]].groupby("num_lanes").mean()
    crowd_light_interval = data[["light_interval", "avg_crowd_size"]].groupby("light_interval").mean()
    crowd_light_interval1 = line1[["light_interval", "avg_crowd_size"]].groupby("light_interval").mean()
    crowd_light_interval2 = line2[["light_interval", "avg_crowd_size"]].groupby("light_interval").mean()
    crowd_light_interval3 = line3[["light_interval", "avg_crowd_size"]].groupby("light_interval").mean()
    crowd_light_interval4 = line4[["light_interval", "avg_crowd_size"]].groupby("light_interval").mean()
    #df = [crowd_light_interval1,crowd_light_interval2,crowd_light_interval3,crowd_light_interval4]
    #newdata =pd.concat(df)

    interval1 = data[data['light_interval'] ==0.5]
    interval2 = data[data['light_interval'] ==1.0]
    interval3 = data[data['light_interval'] ==1.5]
    interval4 = data[data['light_interval'] ==2.0]
    crowd_lanes1 = interval1[["num_lanes","light_interval", "avg_crowd_size"]].groupby("num_lanes").mean()
    crowd_lanes2 = interval2[["num_lanes","light_interval", "avg_crowd_size"]].groupby("num_lanes").mean()
    crowd_lanes3 = interval3[["num_lanes","light_interval", "avg_crowd_size"]].groupby("num_lanes").mean()
    crowd_lanes4 = interval4[["num_lanes","light_interval", "avg_crowd_size"]].groupby("num_lanes").mean()
    #df2 = [crowd_lanes1,crowd_lanes2,crowd_lanes3,crowd_lanes4]
    #newdata2 =pd.concat(df2)

    
    fig = make_subplots(
        rows=3, cols=1,
        vertical_spacing=0.15,
        subplot_titles=("no.of lanes VS average crowd size",
                        "traffic light interval VS average crowd size",
                        "Heatmap between traffic light interval and average crowd size"),
        row_heights=[0.6,0.6,0.95])
        

    fig.add_trace(
    go.Heatmap(x = crowd_heat_df["num_lanes"],
        y =  crowd_heat_df["light_interval"],
        z =  crowd_heat_df["avg_crowd_size"],
               colorbar=dict(y=0.16,len=.3)
        ),
    row=3, col=1,
    )

    #first graph with four lines
    trace_1 = go.Line(x = crowd_lanes1.index,
                      y = crowd_lanes1["avg_crowd_size"],
                      name = "light_interval = 0.5",
                      legendgroup='1')
    trace_2 = go.Line(x = crowd_lanes2.index,
                      y = crowd_lanes2["avg_crowd_size"],
                      name = "light_interval = 1.0",
                      #legendgroup='1'
                      )
    trace_3 = go.Line(x = crowd_lanes3.index,
                      y = crowd_lanes3["avg_crowd_size"],
                      name = "light_interval = 1.5",
                      #legendgroup='1'
                      )
    trace_4 = go.Line(x = crowd_lanes4.index,
                      y = crowd_lanes4["avg_crowd_size"],
                      name = "light_interval = 2.0",
                      #legendgroup='1'
                      )
    
    
    fig.add_trace(trace_1,
    row=1, col=1,
    )
    fig.add_trace(trace_2,
    row=1, col=1,
    )
    fig.add_trace(trace_3,
    row=1, col=1,
    )
    fig.add_trace(trace_4,
    row=1, col=1,
    )

    #second graph with four lines
    trace1 =go.Line(x = crowd_light_interval1.index,
        y = crowd_light_interval1["avg_crowd_size"],
                    name = "number of lanes = 1",
                    legendgroup='2'
        )
    
    trace2 =go.Line(x = crowd_light_interval2.index,
        y = crowd_light_interval2["avg_crowd_size"],
                    name = "number of lanes = 2",
                    #legendgroup='2'
        )

    trace3 =go.Line(x = crowd_light_interval3.index,
        y = crowd_light_interval3["avg_crowd_size"],
                    name = "number of lanes = 3",
                    #legendgroup='2'
        )

    trace4 =go.Line(x = crowd_light_interval4.index,
        y = crowd_light_interval4["avg_crowd_size"],
                    name = "number of lanes = 4",
                    #legendgroup='2'
        )
    
    fig.add_trace(trace1,
    row=2, col=1,
    )

    fig.add_trace(trace2,
    row=2, col=1,
    )

    fig.add_trace(trace3,
    row=2, col=1,
    )

    fig.add_trace(trace4,
    row=2, col=1,
    )
    

    
    
    fig.update_xaxes(title_text="Traffic light interval", row=2, col=1)
    fig.update_xaxes(title_text="Number of Lanes", row=1, col=1)
    fig.update_xaxes(title_text="Number of lines", row=3, col=1)

    fig.update_yaxes(title_text="Average Crowd Size", row=2, col=1)
    fig.update_yaxes(title_text="Average Crowd Size", row=1, col=1)
    fig.update_yaxes(title_text="Traffic light interval", row=3, col=1)
    fig.update_layout(
        height = 800,
        width = 800,
        #legend_tracegroupgap = 180,
        showlegend=True
    )


    return fig

### TAB 2-2 GRAPHS
def create_plot_car(num_cars = 10, num_ped = 10, patience=0.6):
    data = get_data(num_cars, num_ped, patience)
    
    line1 = data[data['num_lanes'] ==1]
    line2 = data[data['num_lanes'] ==2]
    line3 = data[data['num_lanes'] ==3]
    line4 = data[data['num_lanes'] ==4]
    
    car_marker_df = data[["num_lanes", "light_interval", "avg_waiting_cars", "no._stopped_cars"]]
    car_marker_df = car_marker_df.groupby(["num_lanes", "light_interval"])["avg_waiting_cars", "no._stopped_cars"].mean().reset_index()
    car_heat_df = data[["num_lanes", "light_interval", "avg_speed_cars"]]
    
    interval1 = data[data['light_interval'] ==0.5]
    interval2 = data[data['light_interval'] ==1.0]
    interval3 = data[data['light_interval'] ==1.5]
    interval4 = data[data['light_interval'] ==2.0]
  
    car_interval1 = line1[["light_interval", "avg_waiting_cars"]].groupby("light_interval").mean()
    car_interval2 = line2[["light_interval", "avg_waiting_cars"]].groupby("light_interval").mean()
    car_interval3 = line3[["light_interval", "avg_waiting_cars"]].groupby("light_interval").mean()
    car_interval4 = line4[["light_interval", "avg_waiting_cars"]].groupby("light_interval").mean()
    
    car_lanes1 = interval1[["num_lanes", "light_interval","avg_waiting_cars"]].groupby("num_lanes").mean()
    car_lanes2 = interval2[["num_lanes","light_interval", "avg_waiting_cars"]].groupby("num_lanes").mean()
    car_lanes3 = interval3[["num_lanes","light_interval", "avg_waiting_cars"]].groupby("num_lanes").mean()
    car_lanes4 = interval4[["num_lanes","light_interval", "avg_waiting_cars"]].groupby("num_lanes").mean()
    

    fig = make_subplots(
        rows=4, cols=1,
        vertical_spacing=0.08,
        subplot_titles=("No.of lanes VS Average waiting time",
            "Traffic light interval VS Average waiting time",
            "Heatmap on Average speed of the car"),
        row_heights=[0.6,0.6,0.95,0.95])

    fig.add_trace(
    go.Scatter(
        mode='markers',
        x=car_marker_df["num_lanes"],
        y=car_marker_df["light_interval"],
        marker=dict(
            color=car_marker_df["no._stopped_cars"],
            size=car_marker_df["avg_waiting_cars"]**3/20000,
            colorscale='sunset',
            showscale=False
        )
    ),
    row=4, col=1,
    )

    fig.add_trace(
    go.Heatmap(x = car_heat_df["num_lanes"],
        y =  car_heat_df["light_interval"],
        z =  car_heat_df["avg_speed_cars"],
        colorbar=dict(y=0.45,len=0.25)),
    row=3, col=1,
    )

    trace1 =go.Line(x = car_interval1.index,
        y = car_interval1["avg_waiting_cars"],
        name = "number of lanes = 1",
        legendgroup='2'
        )

    trace2 =go.Line(x = car_interval2.index,
        y = car_interval2["avg_waiting_cars"],
        name = "number of lanes = 2",
        )

    trace3 =go.Line(x = car_interval3.index,
        y = car_interval3["avg_waiting_cars"],
        name = "number of lanes = 3",
        )

    trace4 =go.Line(x = car_interval4.index,
        y = car_interval4["avg_waiting_cars"],
        name = "number of lanes = 4",               
        )

    fig.add_trace(trace1, row=2, col=1,),
    fig.add_trace(trace2, row=2, col=1,),
    fig.add_trace(trace3, row=2, col=1,),
    fig.add_trace(trace4, row=2, col=1,),



    #first graph with four lines
    trace_1 = go.Line(x = car_lanes1.index,
                      y = car_lanes1["avg_waiting_cars"],
                      name = "light_interval = 0.5",
                      legendgroup='1')
    trace_2 = go.Line(x = car_lanes2.index,
                      y = car_lanes2["avg_waiting_cars"],
                      name = "light_interval = 1.0",
                      #legendgroup='1'
                      )
    trace_3 = go.Line(x = car_lanes3.index,
                      y = car_lanes3["avg_waiting_cars"],
                      name = "light_interval = 1.5",
                      #legendgroup='1'
                      )
    trace_4 = go.Line(x = car_lanes4.index,
                      y = car_lanes4["avg_waiting_cars"],
                      name = "light_interval = 2.0",
                      #legendgroup='1'
                      )
    
    
    fig.add_trace(trace_1,
    row=1, col=1,
    )
    fig.add_trace(trace_2,
    row=1, col=1,
    )
    fig.add_trace(trace_3,
    row=1, col=1,
    )
    fig.add_trace(trace_4,
    row=1, col=1,
    )


    fig.update_xaxes(title_text="Number of Lanes", row=1, col=1)
    fig.update_xaxes(title_text="Light Interval", row=2, col=1)
    fig.update_xaxes(title_text="Number of Lanes", row=3, col=1)
    fig.update_xaxes(title_text="Number of Lanes", row=4, col=1)
    
    fig.update_yaxes(title_text="Average Waiting Time", row=1, col=1)
    fig.update_yaxes(title_text="Average Waiting Time", row=2, col=1)
    fig.update_yaxes(title_text="Light Interval", row=3, col=1)
    fig.update_yaxes(title_text="Light Interval", row=4, col=1)
    fig.update_layout(
        height = 1200,
        width = 800,
        showlegend=True
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
