# PowerShell script for quick testing (reduced dataset and seed counts)

# Reduced configuration for testing
# Note: Skipping index 2 (hmp-task-gastro-oral-reduced) as the dataset file is missing
$task_idxs = 0,1,3   # Only datasets 0, 1, and 3 (skipping 2)
$seeds = 0..1        # Only 2 seeds

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AugCoDa Quick Test Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "This is a REDUCED test configuration:" -ForegroundColor Yellow
Write-Host "  - Datasets: $($task_idxs.Count) (indices $($task_idxs[0])-$($task_idxs[-1]))" -ForegroundColor White
Write-Host "  - Seeds: $($seeds.Count) (indices $($seeds[0])-$($seeds[-1]))" -ForegroundColor White
Write-Host ""

$total_per_method = $task_idxs.Count * $seeds.Count
$total_all = $total_per_method * 4

Write-Host "Total experiments: $total_all" -ForegroundColor Green
Write-Host "  - $total_per_method per method x 4 methods" -ForegroundColor White
Write-Host ""
Write-Host "Starting in 3 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
Write-Host ""

$start_time = Get-Date
$completed = 0
$failed = 0
$success = 0

# Fast method
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing FAST method" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($i in $task_idxs) {
    foreach ($s in $seeds) {
        $completed++
        Write-Host "[$completed/$total_all] Fast: data_idx=$i, seed=$s" -ForegroundColor Yellow
        
        try {
            python code/train_and_evaluate.py --data_idx=$i --seed=$s --method=fast
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Success" -ForegroundColor Green
                $success++
            } else {
                Write-Host "  ✗ Failed" -ForegroundColor Red
                $failed++
            }
        }
        catch {
            Write-Host "  ✗ Error: $_" -ForegroundColor Red
            $failed++
        }
        Write-Host ""
    }
}

# DeepMicro method
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing DEEPMICRO method" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($i in $task_idxs) {
    foreach ($s in $seeds) {
        $completed++
        Write-Host "[$completed/$total_all] DeepMicro: data_idx=$i, seed=$s" -ForegroundColor Yellow
        
        try {
            python code/train_and_evaluate.py --data_idx=$i --seed=$s --method=deepmicro
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Success" -ForegroundColor Green
                $success++
            } else {
                Write-Host "  ✗ Failed" -ForegroundColor Red
                $failed++
            }
        }
        catch {
            Write-Host "  ✗ Error: $_" -ForegroundColor Red
            $failed++
        }
        Write-Host ""
    }
}

# Contrastive method
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing CONTRASTIVE method" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($i in $task_idxs) {
    foreach ($s in $seeds) {
        $completed++
        Write-Host "[$completed/$total_all] Contrastive: data_idx=$i, seed=$s" -ForegroundColor Yellow
        
        try {
            python code/train_and_evaluate.py --data_idx=$i --seed=$s --method=contrastive
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Success" -ForegroundColor Green
                $success++
            } else {
                Write-Host "  ✗ Failed" -ForegroundColor Red
                $failed++
            }
        }
        catch {
            Write-Host "  ✗ Error: $_" -ForegroundColor Red
            $failed++
        }
        Write-Host ""
    }
}

# MAML method
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing MAML method" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($i in $task_idxs) {
    foreach ($s in $seeds) {
        $completed++
        Write-Host "[$completed/$total_all] MAML: data_idx=$i, seed=$s" -ForegroundColor Yellow
        
        try {
            python code/train_and_evaluate.py --data_idx=$i --seed=$s --method=maml
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Success" -ForegroundColor Green
                $success++
            } else {
                Write-Host "  ✗ Failed" -ForegroundColor Red
                $failed++
            }
        }
        catch {
            Write-Host "  ✗ Error: $_" -ForegroundColor Red
            $failed++
        }
        Write-Host ""
    }
}

# Summary
$end_time = Get-Date
$duration = $end_time - $start_time

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "QUICK TEST COMPLETED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total: $total_all | Success: $success | Failed: $failed" -ForegroundColor White
Write-Host "Duration: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor Yellow
Write-Host ""

if ($failed -eq 0) {
    Write-Host "✓ All tests passed! Ready to run full experiments." -ForegroundColor Green
    Write-Host "  Run: .\code\1_submit_jobs.ps1" -ForegroundColor Cyan
} else {
    Write-Host "⚠ Some tests failed. Please check the errors above." -ForegroundColor Red
}
Write-Host ""
