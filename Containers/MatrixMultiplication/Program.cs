using System.Diagnostics;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(p => p.AddPolicy("corsapp", builder =>
{
    builder.WithOrigins("*").AllowAnyMethod().AllowAnyHeader();
}));

// Add services to the container.

var app = builder.Build();

// Configure the HTTP request pipeline.

app.UseHttpsRedirection();

app.UseCors("corsapp");

app.MapGet("/start", () =>
{
    Random rnd = new Random();
    int[,] matrix1 = new int[100, 100];
    for (int i = 0; i < matrix1.GetLength(0); i++)
    {
        for (int j = 0; j < matrix1.GetLength(1); j++)
            matrix1[i, j] = rnd.Next(1, 10);
    }

    int[,] matrix2 = new int[100, 100];
    for (int i = 0; i < matrix2.GetLength(0); i++)
    {
        for (int j = 0; j < matrix2.GetLength(1); j++)
            matrix2[i, j] = rnd.Next(1, 10);
    }



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
        int[,] c = new int[100, 100];
        for (int i = 0; i < c.GetLength(0); i++)
        {
            for (int j = 0; j < c.GetLength(1); j++)
            {
                c[i, j] = 0;
                for (int k = 0; k < 2; k++)
                {
                    c[i, j] += matrix1[i, k] * matrix2[k, j];
                }
            }
        }
        for (int i = 0; i < c.GetLength(0); i++)
        {
            for (int j = 0; j < c.GetLength(1); j++)
            {
                Console.Write(c[i, j] + "\t");
            }
            Console.WriteLine();
        }
    }

});

app.Run();
