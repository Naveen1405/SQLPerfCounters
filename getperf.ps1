#getperf.ps1
#Evaluates the SQL Server instances on a Windows server and returns performance data for each instance running
#cls

param(
	[string]$srv="<ServerName>",
	[int]$interval=30,
	[datetime]$endat="03/02/2023 10:30",
    [string]$inst='MSSQLSERVER'
	)

if ($PSVersionTable.PSVersion.Major -eq 1 -or $PSVersionTable.PSVersion.Major -eq 2)
{
    if ( (Get-PSSnapin -Name SqlServerCmdletSnapin100 -ErrorAction SilentlyContinue) -eq $null )
        {Add-PSSnapin SqlServerCmdletSnapin100}
    if ( (Get-PSSnapin -Name SqlServerCmdletSnapin100 -ErrorAction SilentlyContinue) -eq $null )
        {Add-PSSnapin SqlServerProviderSnapin100}
} 

if ($inst -ne 'MSSQLSERVER')
{
    $inst='MSSQL$'+$inst
    $inst2=$inst
}
else
{
    $inst2='SQLServer'
}

#Define the destination server and database names
$sqlsrv = "<DestinationServer>"
$destdb = "<DestinationDB>"

#Initialize the Performance Counters for the machine
$ppt = New-Object System.Diagnostics.PerformanceCounter
$ppt.CategoryName = 'Processor'
$ppt.CounterName = '% Processor Time'
$ppt.InstanceName = '_Total'
$pptv = $ppt.NextValue()
$pprt = New-Object System.Diagnostics.PerformanceCounter
$pprt.CategoryName = 'Processor'
$pprt.CounterName = '% Privileged Time'
$pprt.InstanceName = '_Total'
$pprtv = $pprt.NextValue()
$ppross = New-Object System.Diagnostics.PerformanceCounter
$ppross.CategoryName = 'Process'
$ppross.CounterName = '% Processor Time'
$ppross.InstanceName = 'sqlservr'
$pprossv = $ppross.NextValue()
$ppriss = New-Object System.Diagnostics.PerformanceCounter
$ppriss.CategoryName = 'Process'
$ppriss.CounterName = '% Privileged Time'
$ppriss.InstanceName = 'sqlservr'
$pprissv = $ppriss.NextValue()
$mab = New-Object System.Diagnostics.PerformanceCounter
$mab.CategoryName = 'Memory'
$mab.CounterName = 'Available MBytes'
$pfu = New-Object System.Diagnostics.PerformanceCounter
$pfu.CategoryName = 'Paging File'
$pfu.CounterName = '% Usage'
$pfu.InstanceName = '_Total'
$drs = New-Object System.Diagnostics.PerformanceCounter
$drs.CategoryName = 'PhysicalDisk'
$drs.CounterName = 'Disk Reads/sec'
$drs.InstanceName = '_Total'
$dws = New-Object System.Diagnostics.PerformanceCounter
$dws.CategoryName = 'PhysicalDisk'
$dws.CounterName = 'Disk Writes/sec'
$dws.InstanceName = '_Total'
$adsr = New-Object System.Diagnostics.PerformanceCounter
$adsr.CategoryName = 'PhysicalDisk'
$adsr.CounterName = 'Avg. Disk sec/Read'
$adsr.InstanceName = '_Total'
$adbr = New-Object System.Diagnostics.PerformanceCounter
$adbr.CategoryName = 'PhysicalDisk'
$adbr.CounterName = 'Avg. Disk bytes/Read'
$adbr.InstanceName = '_Total'
$adsw = New-Object System.Diagnostics.PerformanceCounter
$adsw.CategoryName = 'PhysicalDisk'
$adsw.CounterName = 'Avg. Disk sec/Write'
$adsw.InstanceName = '_Total'
$adbw = New-Object System.Diagnostics.PerformanceCounter
$adbw.CategoryName = 'PhysicalDisk'
$adbw.CounterName = 'Avg. Disk bytes/Write'
$adbw.InstanceName = '_Total'
$pctit = New-Object System.Diagnostics.PerformanceCounter
$pctit.CategoryName = 'PhysicalDisk'
$pctit.CounterName = '% Idle Time'
$pctit.InstanceName = '_Total'
$cdql = New-Object System.Diagnostics.PerformanceCounter
$cdql.CategoryName = 'PhysicalDisk'
$cdql.CounterName = 'Current Disk Queue Length'
$cdql.InstanceName = '_Total'
$pql = New-Object System.Diagnostics.PerformanceCounter
$pql.CategoryName = 'System'
$pql.CounterName = 'Processor Queue Length'

#Initialize our instance counter collections
$fr = @()
$ps = @()
$fs = @()
$rs = @()
$bch = @()
$ple = @()
$lg = @()
$bp = @()
$brs = @()
$cs = @()
$rcs = @()
$lws = @()
$cps = @()
$lcws = @()
$mgp = @()
$trsm = @()
$tosm = @()


$inst | ForEach-Object { 
	if ($_.Name -eq $inst) {
		$srvnm = $_.Name
		}
	else {
		$srvnm = $inst + $_.Name
		}
	$stat = get-service -name $srvnm | select Status
	if ($stat.Status -eq 'Running') {
		$iname = $srvnm
		if ($iname -eq $inst) {
			$iname = $inst2
			}
		
		#Initialize the performance counters for each instance
		$frinit = New-Object System.Diagnostics.PerformanceCounter
		$frinit.CategoryName = $iname + ':Access Methods'
		$frinit.CounterName = 'Forwarded Records/sec'
		$frv = $frinit.NextValue()
		$fr += $frinit
		$psinit = New-Object System.Diagnostics.PerformanceCounter
		$psinit.CategoryName = $iname + ':Access Methods'
		$psinit.CounterName = 'Page Splits/sec'
		$psv = $psinit.NextValue()
		$ps += $psinit
        $fsinit = New-Object System.Diagnostics.PerformanceCounter
		$fsinit.CategoryName = $iname + ':Access Methods'
		$fsinit.CounterName = 'Full Scans/sec'
		$fsv = $fsinit.NextValue()
		$fs += $fsinit
        $rsinit = New-Object System.Diagnostics.PerformanceCounter
		$rsinit.CategoryName = $iname + ':Access Methods'
		$rsinit.CounterName = 'Range Scans/sec'
		$rsv = $rsinit.NextValue()
		$rs += $rsinit
		$bchinit = New-Object System.Diagnostics.PerformanceCounter
		$bchinit.CategoryName = $iname + ':Buffer Manager'
		$bchinit.CounterName = 'Buffer cache hit ratio'
		$bchv = $bchinit.NextValue()
		$bch += $bchinit
		$pleinit = New-Object System.Diagnostics.PerformanceCounter
		$pleinit.CategoryName = $iname + ':Buffer Manager'
		$pleinit.CounterName = 'Page life expectancy'
		$plev = $pleinit.NextValue()
		$ple += $pleinit
		$lginit = New-Object System.Diagnostics.PerformanceCounter
		$lginit.CategoryName = $iname + ':Databases'
		$lginit.CounterName = 'Log Growths'
		$lginit.InstanceName = '_Total'
		$lgv = $lginit.NextValue()
		$lg += $lginit
		$bpinit = New-Object System.Diagnostics.PerformanceCounter
		$bpinit.CategoryName = $iname + ':General Statistics'
		$bpinit.CounterName = 'Processes blocked'
		$bpv = $bpinit.NextValue()
		$bp += $bpinit
		$brsinit = New-Object System.Diagnostics.PerformanceCounter
		$brsinit.CategoryName = $iname + ':SQL Statistics'
		$brsinit.CounterName = 'Batch Requests/sec'
		$brsv = $brsinit.NextValue()
		$brs += $brsinit
		$csinit = New-Object System.Diagnostics.PerformanceCounter
		$csinit.CategoryName = $iname + ':SQL Statistics'
		$csinit.CounterName = 'SQL Compilations/sec'
		$csv = $csinit.NextValue()
		$cs += $csinit
		$rcsinit = New-Object System.Diagnostics.PerformanceCounter
		$rcsinit.CategoryName = $iname + ':SQL Statistics'
		$rcsinit.CounterName = 'SQL Re-Compilations/sec'
		$rcsv = $rcsinit.NextValue()
		$rcs += $rcsinit
        $lwsinit = New-Object System.Diagnostics.PerformanceCounter
		$lwsinit.CategoryName = $iname + ':Buffer Manager'
		$lwsinit.CounterName = 'Lazy writes/sec'
		$lwsv = $lwsinit.NextValue()
		$lws += $lwsinit
        $cpsinit = New-Object System.Diagnostics.PerformanceCounter
		$cpsinit.CategoryName = $iname + ':Buffer Manager'
		$cpsinit.CounterName = 'Checkpoint pages/sec'
		$cpsv = $cpsinit.NextValue()
		$cps += $cpsinit
        $lcwsinit = New-Object System.Diagnostics.PerformanceCounter
		$lcwsinit.CategoryName = $iname + ':Locks'
		$lcwsinit.CounterName = 'Lock Waits/sec'
        $lcwsinit.InstanceName = '_Total'
		$lcwsv = $lcwsinit.NextValue()
		$lcws += $lcwsinit
        $mgpinit = New-Object System.Diagnostics.PerformanceCounter
		$mgpinit.CategoryName = $iname + ':Memory Manager'
		$mgpinit.CounterName = 'Memory Grants Pending'
		$mgpv = $mgpinit.NextValue()
		$mgp += $mgpinit
        $trsminit = New-Object System.Diagnostics.PerformanceCounter
		$trsminit.CategoryName = $iname + ':Memory Manager'
		$trsminit.CounterName = 'Target Server Memory (KB)'
		$trsmv = $trsminit.NextValue()
		$trsm += $trsminit
		$tosminit = New-Object System.Diagnostics.PerformanceCounter
		$tosminit.CategoryName = $iname + ':Memory Manager'
		$tosminit.CounterName = 'Total Server Memory (KB)'
		$tosmv = $tosminit.NextValue()
		$tosm += $tosminit
        }
	}
		
while ($endat -gt (get-date)) {
	$dt = (Get-Date -Format "dd-MM-yyyy HH:mm:ss")
	
	#Send the next set of machine counters to our database
	$q = "declare @ServerID int; exec [PerfMon].[insServerStats]"
	$q = $q + " @ServerID OUTPUT"
	$q = $q + ", @ServerNm='" + [string]$srv + "'"
	$q = $q + ", @PerfDate='" + [string]$dt + "'"
	$q = $q + ", @PctProc=" + [string]$ppt.NextValue()
    $q = $q + ", @PctPriv=" + [string]$pprt.NextValue()
    $q = $q + ", @SQLPctProc=" + [string]$ppross.NextValue()
    $q = $q + ", @SQLPctPriv=" + [string]$ppriss.NextValue()
	$q = $q + ", @Memory=" + [string]$mab.NextValue()
	$q = $q + ", @PgFilUse=" + [string]$pfu.NextValue()
	$q = $q + ", @DskRdsSec=" + [string]$drs.NextValue()
	$q = $q + ", @DskWrtSec=" + [string]$dws.NextValue()
    $q = $q + ", @AvgDskSecRds=" + [string]$adsr.NextValue()
    $q = $q + ", @AvgDskbytesRds=" + [string]$adbr.NextValue()
    $q = $q + ", @AvgDskSecWrt=" + [string]$adsw.NextValue()
    $q = $q + ", @AvgDskbytesWrt=" + [string]$adbw.NextValue()
    $q = $q + ", @PctIdleTm=" + [string]$pctit.NextValue()
    $q = $q + ", @CurDskQueLn=" + [string]$cdql.NextValue()
	$q = $q + ", @ProcQueLn=" + [string]$pql.NextValue()
	$q = $q + "; select @ServerID as ServerID"
	$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
	$SrvID = $res.ServerID


	#Now loop through the existing instances and initialize the counters for each SQL Server instance
	$i = 0
	$inst | ForEach-Object { 
		if ($_.Name -eq $inst) {
			$srvnm = $_.Name
			}
		else {
			$srvnm = $inst + $_.Name
			}
		$stat = get-service -name $srvnm | select Status
		if ($stat.Status -eq 'Running') {
			$iname = $srvnm
			if ($iname -eq $inst) {
				$iname = $inst2
				}
			
			#Send the next set of instance counters to the database
			$q = "declare @InstanceID int; exec [PerfMon].[insInstanceStats]"
			$q = $q + " @InstanceID OUTPUT"
			$q = $q + ", @ServerID=" + [string]$SrvID
			$q = $q + ", @ServerNm='" + [string]$srv + "'"
			$q = $q + ", @InstanceNm='" + [string]$_.Name + "'"
			$q = $q + ", @PerfDate='" + [string]$dt + "'"
			$q = $q + ", @FwdRecSec=" + [string]$fr[$i].NextValue()
			$q = $q + ", @PgSpltSec=" + [string]$ps[$i].NextValue()
            $q = $q + ", @TotTblScn=" + [string]$fs[$i].NextValue()
            $q = $q + ", @TotTblSks=" + [string]$rs[$i].NextValue()
			$q = $q + ", @BufCchHit=" + [string]$bch[$i].NextValue()
			$q = $q + ", @PgLifeExp=" + [string]$ple[$i].NextValue()
			$q = $q + ", @LogGrwths=" + [string]$lg[$i].NextValue()
			$q = $q + ", @BlkProcs=" + [string]$bp[$i].NextValue()
			$q = $q + ", @BatReqSec=" + [string]$brs[$i].NextValue()
			$q = $q + ", @SQLCompSec=" + [string]$cs[$i].NextValue()
			$q = $q + ", @SQLRcmpSec=" + [string]$rcs[$i].NextValue()
            $q = $q + ", @LzyWrtSec=" + [string]$lws[$i].NextValue()
            $q = $q + ", @CptPgsSec=" + [string]$cps[$i].NextValue()
            $q = $q + ", @LckWtsSec=" + [string]$lcws[$i].NextValue()
            $q = $q + ", @MemGrtPend=" + [string]$mgp[$i].NextValue()
            $q = $q + ", @TgtSvrMemKB=" + [string]$trsm[$i].NextValue()
            $q = $q + ", @TotSvrMemKB=" + [string]$trsm[$i].NextValue()
			$q = $q + "; select @InstanceID as InstanceID"
			$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
			$InstID = $res.InstanceID
			$i += 1
			
			}
		}
	
	Start-Sleep -s $interval
	}

