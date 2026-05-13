import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import seaborn as sns
import mysql.connector

# ---------------------------------------------------------------
# MySQL connection parameters
# ---------------------------------------------------------------
DB_HOST     = "127.0.0.1"
DB_PORT     = 3306
DB_USER     = "root"
DB_PASSWORD = "sesame80"
DB_NAME     = "case_studies"

OUTPUT_FOLDER = "/Users/laragon/Desktop/movie_project/"

# ---------------------------------------------------------------
# CONNECT TO MYSQL
# ---------------------------------------------------------------
conn = mysql.connector.connect(
    host=DB_HOST,
    port=DB_PORT,
    user=DB_USER,
    password=DB_PASSWORD,
    database=DB_NAME
)
print("Connected to MySQL successfully!")

# ---------------------------------------------------------------
# PULLING DATA FROM TABLES
# ---------------------------------------------------------------
barbie_ts    = pd.read_sql("SELECT * FROM barbie_trends_time_series", conn)
minecraft_ts = pd.read_sql("SELECT * FROM minecraft_movie_time_series", conn)
mario_ts     = pd.read_sql("SELECT * FROM supermario_time_series", conn)
box_office   = pd.read_sql("SELECT * FROM positive_publicity_examples", conn)

conn.close() # Always good to close the connection when done
print("Data loaded from MySQL!")

# ---------------------------------------------------------------
# PREP TIME SERIES DATA FOR LINE CHART
# ---------------------------------------------------------------
barbie_ts["Time"]    = pd.to_datetime(barbie_ts["Time"])
minecraft_ts["Time"] = pd.to_datetime(minecraft_ts["Time"])
mario_ts["Time"]     = pd.to_datetime(mario_ts["Time"])

ts = barbie_ts.merge(minecraft_ts, on="Time").merge(mario_ts, on="Time")
ts.columns = ["Time", "Barbie", "Minecraft Movie", "Super Mario Bros."]
ts = ts[ts["Time"] >= "2022-01-01"].reset_index(drop=True)

# ---------------------------------------------------------------
# PREP BOX OFFICE DATA FROM positive_publicity_examples TABLE 
# ---------------------------------------------------------------
box_office = box_office.sort_values("worldwide_revenue", ascending=False)
movies        = box_office["movie_title"].tolist()
worldwide     = (box_office["worldwide_revenue"] / 1_000_000).tolist()
domestic      = (box_office["domestic_revenue"]  / 1_000_000).tolist()
international = [(w - d) for w, d in zip(worldwide, domestic)]
budget        = (box_office["budget"] / 1_000_000).tolist()
roi           = [round((w - b) / b * 100) for w, b in zip(worldwide, budget)]
months_above  = [4, 4, 3]

# ---------------------------------------------------------------
# CHART STYLING
# ---------------------------------------------------------------
sns.set_theme(style="whitegrid", font_scale=1.1)
COLORS = {
    "Barbie":            "#E24B4A",
    "Super Mario Bros.": "#1D9E75",
    "Minecraft Movie":   "#378ADD"
}
PURPLE = "#534AB7"
AMBER  = "#EF9F27"
TEAL_D = "#1D9E75"
TEAL_L = "#9FE1CB"

# ---------------------------------------------------------------
# VISUAL 1: Google Trends search interest over time
# ---------------------------------------------------------------
fig, ax = plt.subplots(figsize=(10, 4))
line_styles = {
    "Barbie":            (None,   2),
    "Super Mario Bros.": ((5, 2), 2),
    "Minecraft Movie":   ((2, 2), 2)
}
for movie, (dash, lw) in line_styles.items():
    ax.plot(ts["Time"], ts[movie], label=movie,
            color=COLORS[movie], linewidth=lw,
            dashes=dash if dash else (None, None))

release_dates = [
    ("Barbie",            "2023-07-01", "Barbie\nreleases"),
    ("Super Mario Bros.", "2023-04-01", "Mario\nreleases"),
    ("Minecraft Movie",   "2025-04-01", "Minecraft\nreleases"),
]
for movie, date, label in release_dates:
    ax.axvline(pd.to_datetime(date), color=COLORS[movie],
               linestyle=":", linewidth=1, alpha=0.6)
    ax.text(pd.to_datetime(date), 85, label,
            color=COLORS[movie], fontsize=8, ha="center")

ax.set_title("Google Trends search interest over time (2022–2026)",
             fontsize=13, fontweight="normal")
ax.set_ylabel("Search interest (0–100)")
ax.legend(frameon=False)
ax.set_ylim(0, 110)
plt.tight_layout()
plt.savefig(OUTPUT_FOLDER + "viz1_search_interest.png", dpi=150, bbox_inches="tight")
plt.show()
print("Saved viz1_search_interest.png")

# ---------------------------------------------------------------
# VISUAL 2: Worldwide revenue vs. budget
# ---------------------------------------------------------------
x     = range(len(movies))
width = 0.35
fig, ax = plt.subplots(figsize=(8, 4))
bars1 = ax.bar([i - width/2 for i in x], worldwide, width,
               label="Worldwide revenue ($M)", color="#E24B4A")
bars2 = ax.bar([i + width/2 for i in x], budget, width,
               label="Budget ($M)", color="#B4B2A9")
ax.set_xticks(list(x))
ax.set_xticklabels(movies)
ax.yaxis.set_major_formatter(
    mticker.FuncFormatter(lambda v, _: f"${int(v):,}M"))
ax.set_title("Worldwide revenue vs. production budget",
             fontsize=13, fontweight="normal")
ax.legend(frameon=False)
ax.bar_label(bars1, fmt=lambda v: f"${int(v):,}M", padding=3, fontsize=9)
ax.bar_label(bars2, fmt=lambda v: f"${int(v):,}M", padding=3, fontsize=9)
plt.tight_layout()
plt.savefig(OUTPUT_FOLDER + "viz2_revenue_vs_budget.png", dpi=150, bbox_inches="tight")
plt.show()
print("Saved viz2_revenue_vs_budget.png")

# ---------------------------------------------------------------
# VISUAL 3: ROI horizontal bar chart
# ---------------------------------------------------------------
roi_sorted = sorted(zip(movies, roi), key=lambda x: x[1], reverse=True)
roi_movies = [r[0] for r in roi_sorted]
roi_vals   = [r[1] for r in roi_sorted]
fig, ax = plt.subplots(figsize=(8, 3))
bars = ax.barh(roi_movies, roi_vals, color=PURPLE)
ax.bar_label(bars, fmt=lambda v: f"{int(v)}%", padding=5, fontsize=10)
ax.xaxis.set_major_formatter(
    mticker.FuncFormatter(lambda v, _: f"{int(v)}%"))
ax.set_title("Return on investment (ROI %)", fontsize=13, fontweight="normal")
ax.set_xlim(0, 1500)
ax.invert_yaxis()
plt.tight_layout()
plt.savefig(OUTPUT_FOLDER + "viz3_roi.png", dpi=150, bbox_inches="tight")
plt.show()
print("Saved viz3_roi.png")

# ---------------------------------------------------------------
# VISUAL 4: Months with search interest above 10
# ---------------------------------------------------------------
fig, ax = plt.subplots(figsize=(7, 3))
bars = ax.bar(movies, months_above, color=AMBER)
ax.bar_label(bars, fmt=lambda v: f"{int(v)} mo", padding=3, fontsize=10)
ax.set_title("Months with search interest above 10/100",
             fontsize=13, fontweight="normal")
ax.set_ylabel("Months")
ax.set_ylim(0, 7)
plt.tight_layout()
plt.savefig(OUTPUT_FOLDER + "viz4_hype_duration.png", dpi=150, bbox_inches="tight")
plt.show()
print("Saved viz4_hype_duration.png")

# ---------------------------------------------------------------
# VISUAL 5: Domestic vs. international stacked bar
# ---------------------------------------------------------------
fig, ax = plt.subplots(figsize=(8, 4))
ax.bar(movies, domestic,      label="Domestic ($M)",      color=TEAL_D)
ax.bar(movies, international, label="International ($M)", color=TEAL_L,
       bottom=domestic)
ax.yaxis.set_major_formatter(
    mticker.FuncFormatter(lambda v, _: f"${int(v):,}M"))
ax.set_title("Domestic vs. international revenue",
             fontsize=13, fontweight="normal")
ax.legend(frameon=False)
for i, (d, intl) in enumerate(zip(domestic, international)):
    ax.text(i, d / 2,        f"${int(d)}M",   ha="center", va="center",
            fontsize=9, color="white", fontweight="bold")
    ax.text(i, d + intl / 2, f"${int(intl)}M", ha="center", va="center",
            fontsize=9, color="#085041")
plt.tight_layout()
plt.savefig(OUTPUT_FOLDER + "viz5_domestic_vs_international.png",
            dpi=150, bbox_inches="tight")
plt.show()
print("Saved viz5_domestic_vs_international.png")

print("\nAll 5 charts saved!")