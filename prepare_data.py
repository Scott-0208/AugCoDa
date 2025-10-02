"""
Script to prepare MLRepo datasets for AugCoDa
Converts MLRepo format to the expected CSV format
"""

import pandas as pd
import os
from pathlib import Path

# Dataset configurations
datasets = [
    {"name": "gevers-task-ileum.txt", "folder": "gevers", "taxonomy": "gg", "otu_suffix": "", "task_name": "task-ileum.txt"},
    {"name": "gevers-task-rectum.txt", "folder": "gevers", "taxonomy": "gg", "otu_suffix": "", "task_name": "task-rectum.txt"},
    {"name": "hmp-task-gastro-oral.txt-reduced", "folder": "hmp", "taxonomy": "gg", "otu_suffix": "-reduced", "task_name": "task-gastro-oral.txt"},
    {"name": "hmp-task-sex.txt", "folder": "hmp", "taxonomy": "gg", "otu_suffix": "", "task_name": "task-sex.txt"},
    {"name": "hmp-task-stool-tongue-paired.txt", "folder": "hmp", "taxonomy": "gg", "otu_suffix": "", "task_name": "task-stool-tongue-paired.txt"},
    {"name": "hmp-task-sub-supragingivalplaque-paired.txt", "folder": "hmp", "taxonomy": "gg", "otu_suffix": "", "task_name": "task-sub-supragingivalplaque-paired.txt"},
    {"name": "kostic-task.txt", "folder": "kostic", "taxonomy": "gg", "otu_suffix": "", "task_name": "task.txt"},
    {"name": "qin2012-task-healthy-diabetes.txt", "folder": "qin2012", "taxonomy": "", "otu_suffix": "", "task_name": "task-healthy-diabetes.txt"},
    {"name": "qin2014-task-healthy-cirrhosis.txt", "folder": "qin2014", "taxonomy": "", "otu_suffix": "", "task_name": "task-healthy-cirrhosis.txt"},
    {"name": "ravel-task-black-hispanic.txt", "folder": "ravel", "taxonomy": "gg", "otu_suffix": "", "task_name": "task-black-hispanic.txt"},
    {"name": "ravel-task-nugent-category.txt", "folder": "ravel", "taxonomy": "gg", "otu_suffix": "", "task_name": "task-nugent-category.txt"},
    {"name": "ravel-task-white-black.txt", "folder": "ravel", "taxonomy": "gg", "otu_suffix": "", "task_name": "task-white-black.txt"},
]

mlrepo_path = Path("MLRepo_temp/datasets")
output_path = Path("in")

# Create output directory if it doesn't exist
output_path.mkdir(exist_ok=True)

print("Converting MLRepo datasets to AugCoDa format...")

for dataset in datasets:
    print(f"\nProcessing {dataset['name']}...")
    
    # Paths
    dataset_folder = mlrepo_path / dataset['folder']
    task_file = dataset_folder / dataset['task_name']
    otu_filename = f"otutable.txt{dataset['otu_suffix']}"
    if dataset['taxonomy']:
        otu_file = dataset_folder / dataset['taxonomy'] / otu_filename
    else:
        otu_file = dataset_folder / otu_filename
    
    # Check if files exist
    if not task_file.exists():
        print(f"  Warning: Task file not found: {task_file}")
        continue
    if not otu_file.exists():
        print(f"  Warning: OTU table not found: {otu_file}")
        continue
    
    # Read task file (labels)
    try:
        y_df = pd.read_csv(task_file, sep='\t', index_col=0)
        print(f"  Labels shape: {y_df.shape}")
    except Exception as e:
        print(f"  Error reading task file: {e}")
        continue
    
    # Read OTU table (features)
    try:
        X_df = pd.read_csv(otu_file, sep='\t', index_col=0)
        # Transpose so rows are samples and columns are features
        X_df = X_df.T
        print(f"  Features shape (before filtering): {X_df.shape}")
    except Exception as e:
        print(f"  Error reading OTU table: {e}")
        continue
    
    # Filter to only samples that are in both files
    common_samples = X_df.index.intersection(y_df.index)
    print(f"  Common samples: {len(common_samples)}")
    
    if len(common_samples) == 0:
        print(f"  Error: No common samples found!")
        continue
    
    X_df = X_df.loc[common_samples]
    y_df = y_df.loc[common_samples]
    
    # Save as CSV files
    base_name = dataset['name'].replace('.txt', '')
    X_output = output_path / f"{base_name}-x.csv"
    y_output = output_path / f"{base_name}-y.csv"
    
    X_df.to_csv(X_output)
    y_df.to_csv(y_output)
    
    print(f"  ✓ Saved to {X_output} and {y_output}")
    print(f"  Final shape: X={X_df.shape}, y={y_df.shape}")

print("\n✓ Data preparation complete!")
print(f"Datasets saved to: {output_path.absolute()}")
