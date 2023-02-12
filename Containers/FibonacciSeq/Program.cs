using System.Diagnostics;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(p => p.AddPolicy("corsapp", builder =>
{
    builder.WithOrigins("*").AllowAnyMethod().AllowAnyHeader();
}));


var app = builder.Build();

app.UseHttpsRedirection();

app.UseCors("corsapp");


app.MapGet("/start", () =>
{
    ulong n1 = 0, n2 = 1, n3 = 0;
    string experimentDurationEnv = Environment.GetEnvironmentVariable("ExperimentDuration");
    int experimentDuration = 60;

    if (!string.IsNullOrEmpty(experimentDurationEnv))
    {
        experimentDuration = int.Parse(experimentDurationEnv);
    }


    Stopwatch stopWatch = new Stopwatch();
    stopWatch.Start();

    while (stopWatch.Elapsed.Minutes <= experimentDuration)
    {
        if ((n1 + n2) > ulong.MaxValue)
        {            
            n3 = 0;
            n1 = 0;
            n2 = 1;
        }
        else{

            n3 = n1 + n2;
            Console.Write(n3 + " \n");
            n1 = n2;
            n2 = n3;
        }
    }
    stopWatch.Stop();


});

app.Run();
