# PowerShell script to run all experiments (Windows equivalent of 1_submit_jobs.sh)

# Count number of datasets (0-10, since we're missing hmp-task-gastro-oral)
$task_idxs = 0..10
$seeds = 0..19

# Display configuration
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AugCoDa Experiment Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Datasets: $($task_idxs.Count) (indices $($task_idxs[0])-$($task_idxs[-1]))" -ForegroundColor White
Write-Host "Seeds: $($seeds.Count) (indices $($seeds[0])-$($seeds[-1]))" -ForegroundColor White
Write-Host ""

# Calculate total experiments
$total_fast = $task_idxs.Count * $seeds.Count
$total_deepmicro = $task_idxs.Count * $seeds.Count
$total_contrastive = $task_idxs.Count * $seeds.Count
$total_maml = $task_idxs.Count * $seeds.Count
$total_all = $total_fast + $total_deepmicro + $total_contrastive + $total_maml

Write-Host "Total experiments planned:" -ForegroundColor Yellow
Write-Host "  - Fast method: $total_fast experiments" -ForegroundColor White
Write-Host "  - DeepMicro method: $total_deepmicro experiments" -ForegroundColor White
Write-Host "  - Contrastive method: $total_contrastive experiments" -ForegroundColor White
Write-Host "  - MAML method: $total_maml experiments" -ForegroundColor White
Write-Host "  - TOTAL: $total_all experiments" -ForegroundColor Green
Write-Host ""
Write-Host "Estimated time: Several hours to days depending on your hardware" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to cancel, or wait 5 seconds to continue..." -ForegroundColor Red
Start-Sleep -Seconds 5
Write-Host ""

$global_start_time = Get-Date
$completed = 0
$failed = 0
$success = 0

# Fast jobs can run in series
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting FAST method experiments" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($i in $task_idxs) {
    foreach ($s in $seeds) {
        $completed++
        $percent = [math]::Round(($completed / $total_all) * 100, 1)
        Write-Host "[$completed/$total_all | $percent%] Fast: data_idx=$i, seed=$s" -ForegroundColor Yellow
        
        try {
            python code/train_and_evaluate.py --data_idx=$i --seed=$s --method=fast 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Success" -ForegroundColor Green
                $success++
            } else {
                Write-Host "  ✗ Failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
                $failed++
            }
        }
        catch {
            Write-Host "  ✗ Error: $_" -ForegroundColor Red
            $failed++
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting DEEPMICRO method experiments" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($i in $task_idxs) {
    foreach ($s in $seeds) {
        $completed++
        $percent = [math]::Round(($completed / $total_all) * 100, 1)
        Write-Host "[$completed/$total_all | $percent%] DeepMicro: data_idx=$i, seed=$s" -ForegroundColor Yellow
        
        try {
            python code/train_and_evaluate.py --data_idx=$i --seed=$s --method=deepmicro 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Success" -ForegroundColor Green
                $success++
            } else {
                Write-Host "  ✗ Failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
                $failed++
            }
        }
        catch {
            Write-Host "  ✗ Error: $_" -ForegroundColor Red
            $failed++
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting CONTRASTIVE method experiments" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($i in $task_idxs) {
    foreach ($s in $seeds) {
        $completed++
        $percent = [math]::Round(($completed / $total_all) * 100, 1)
        Write-Host "[$completed/$total_all | $percent%] Contrastive: data_idx=$i, seed=$s" -ForegroundColor Yellow
        
        try {
            python code/train_and_evaluate.py --data_idx=$i --seed=$s --method=contrastive 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Success" -ForegroundColor Green
                $success++
            } else {
                Write-Host "  ✗ Failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
                $failed++
            }
        }
        catch {
            Write-Host "  ✗ Error: $_" -ForegroundColor Red
            $failed++
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting MAML method experiments" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($i in $task_idxs) {
    foreach ($s in $seeds) {
        $completed++
        $percent = [math]::Round(($completed / $total_all) * 100, 1)
        Write-Host "[$completed/$total_all | $percent%] MAML: data_idx=$i, seed=$s" -ForegroundColor Yellow
        
        try {
            python code/train_and_evaluate.py --data_idx=$i --seed=$s --method=maml 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Success" -ForegroundColor Green
                $success++
            } else {
                Write-Host "  ✗ Failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
                $failed++
            }
        }
        catch {
            Write-Host "  ✗ Error: $_" -ForegroundColor Red
            $failed++
        }
    }
}

# Final summary
$global_end_time = Get-Date
$duration = $global_end_time - $global_start_time

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ALL EXPERIMENTS COMPLETED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total experiments: $total_all" -ForegroundColor White
Write-Host "Successful: $success" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor Red
Write-Host "Duration: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor Yellow
Write-Host ""
Write-Host "Results saved in:" -ForegroundColor White
Write-Host "  - ./out/mlrepo12/" -ForegroundColor Cyan
Write-Host "  - ./out/mlrepo12deepmicro/" -ForegroundColor Cyan
Write-Host "  - ./out/mlrepo12contrastive/" -ForegroundColor Cyan
Write-Host "  - ./out/mlrepo12maml/" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run: python code/2_aggregate_results.py" -ForegroundColor White
Write-Host "  2. Run: python code/3_generate_tables.py" -ForegroundColor White
Write-Host "  3. Run: python code/4_generate_fig.py" -ForegroundColor White
Write-Host ""
