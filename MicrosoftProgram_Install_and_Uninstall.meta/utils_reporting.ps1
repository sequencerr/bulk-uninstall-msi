#################################################################################
# utils_reporting.ps1
# 
# Helper functions for adding data to the diagnostic report
# Copyright © 2009, Microsoft Corporation. All rights reserved.
#		
# You may use this code and information and create derivative works of it,
# provided that the following conditions are met:
# 1. This code and information and any derivative works may only be used for
# troubleshooting a) Windows and b) products for Windows, in either case using
# the Windows Troubleshooting Platform
# 2. Any copies of this code and information
# and any derivative works must retain the above copyright notice, this list of
# conditions and the following disclaimer.
# 3. THIS CODE AND INFORMATION IS PROVIDED ``AS IS'' WITHOUT WARRANTY OF ANY 
# KIND, WHETHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. IF THIS
# CODE AND INFORMATION IS USED OR MODIFIED, THE ENTIRE RISK OF USE OR RESULTS IN
# CONNECTION WITH THE USE OF THIS CODE AND INFORMATION REMAINS WITH THE USER.
#################################################################################

# Format-DiagReport
# Format-DiagChart
# Set-DiagPID
# StrArrayTo-ObjArray

function Format-DiagReport ([string]$Style, [System.Xml.XmlDocument]$xml)
{
	$xmlBase = $xml.PSBase
    $xmlNode = $xmlBase.SelectSingleNode("//Objects")
    [System.Xml.XmlAttribute]$attrib = $xmlBase.CreateAttribute("style")

    if ($style.length -gt 0)
    {
        switch ($Style)
        {
            "column" {
                $xmlNode.setattribute("style", "$style")
                
                $headerItems = @()
                
                $xmlNode.SelectNodes("//Property") | ForEach-Object {
                    if ($headeritems -contains $_.name) {
                    }
                    else
                    {
                        $headeritems += $_.name
                    }
                }
                
                $headerNode = $xmlBase.CreateElement("Header")
                
                $xmlNode.appendchild($headernode) > $null
                
                $headeritems | ForEach-Object {
                    $prop = $xmlBase.CreateElement("Property")
                    $prop.setattribute("Name", "$_")
                    $headerNode.appendchild($prop) > $null 
                }
            }
            
            "literal" { 
                $xmlnode.setattribute("style", "$style")
            }
            
            default {
                $xmlnode.setattribute("style", "unsupported")
            }
                    
        }
    }
    $xmlBase.outerxml
}

function Format-DiagChart ($object, $PropNameField, $PropValueField, $PropMaxValueField, $absolute, $Title, $style)
{
    $xmlStrings
    
    $minVal = 0
    $maxVal = 0
    
    #get min and max values
    if ($absolute -eq 1)
    {
        for ($i = 0; $i -lt $object.length; $i++)
        {
            if ($object[$i]."$PropMaxValueField" -gt $maxVal)
            {
                $maxVal = $object[$i]."$PropMaxValueField"
            }
            if ($object[$I]."$PropMaxValueField" -lt $minVal)
            {
                $minVal = $object[$i]."$PropMaxValueField"
            }
        }
    }

    #Add each item to chart
    for ($i = 0; $i -lt $object.length; $i++)
    {
        if ($absolute -ne 1)
        {
            $maxval = 0
            $minval = 0
            
            if ($object[$i]."$PropMaxValueField" -gt $maxVal)
            {
                $maxVal = $object[$i]."$PropMaxValueField"
            }
            if ($object[$I]."$PropMaxValueField" -lt $minVal)
            {
                $minVal = $object[$i]."$PropMaxValueField"
            }
        }
        $itemSize = [math]::round(($object[$i]."$PropValueField" / $maxval) * 100,1)
        if ($itemSize -le 0)
        {
            $itemSize = 0
        }
        $itemValue = $object[$i]."$PropValueField"
        
        $itemName = $object[$i]."$PropNameField"
        $xmlStrings = $xmlStrings + "<Property Name='$itemName' Size='$itemSize' Label='$itemValue'/>"
    }
    
    $xmlstrings = $xmlstrings.insert(0, "<Objects style='$style'><Object Name='$Title'>")
    $xmlstrings = $xmlstrings + "</Object></Objects>"
    
    $xmlstrings
    
}

# Place ProductID in Debug Report
function Set-DiagPID([string]$ProductName, [string]$ProductID)
{
	$PIDObject = "" | Select-Object ProductName						# Return object
	$PIDObject.ProductName = $ProductName
	
	add-member -inputobject $PIDObject -membertype noteproperty -name ProductID -value $ProductID
	
	(convertto-xml -InputObject $PIDObject) | update-diagreport -id OAS_DATAPOINT_ID -name "OAS_DATAPOINT" -description "OAS Data Point for OAS submission" -verbosity debug
}

function StrArrayTo-ObjArray([Array]$strArray, [string]$PropertyName='Name')
{
	$Output = @() 
	
	foreach($item in $strArray)
	{
		$TableEntry = New-Object System.Object
		$TableEntry | Add-Member -type NoteProperty -Name $PropertyName -Value $item
		$Output += $TableEntry
	}
	
	return $Output
}
# SIG # Begin signature block
# MIIauQYJKoZIhvcNAQcCoIIaqjCCGqYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZMR644N/srVeMxzeVEZzGS0Z
# 3WmgghWCMIIEwzCCA6ugAwIBAgITMwAAAIpX6omjSeuL6AAAAAAAijANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTUxMDA3MTgxNDAy
# WhcNMTcwMTA3MTgxNDAyWjCBszELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UECxMebkNpcGhlciBEU0UgRVNO
# OkIxQjctRjY3Ri1GRUMyMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy8XCCCFsLcM0
# BUnA5TXkIRx+hkXEljDvD+u/MlomeT/pmRbc+4l1oz3FZZoq2aEbKmvJJ56sZZe5
# TbIOgsQAg9iR4ienNO29HtQSlDRE6NoL6QUBS+pVz4pKt5g3Kr7n5w2NPfmn1syY
# AeqQpJmXvwSLX0RFW8hZy6dxQxFqYt/mJehuNbrSiCwDifFnRmEzm4M+s2WJt6dg
# Xo7R3ORQCTw/C+cchNZlzJfRyzG1Igx/7gcKDc1A5Uw5N2oGtlnd4i6QaRvXd5+b
# 3K4vKEBkoABk/a6gbrtJ+18OCdEEHMO+yJPvasooaDOco+3zv6ougZoD7lgM1DdG
# XyRu8bHQ7wIDAQABo4IBCTCCAQUwHQYDVR0OBBYEFD0WsZSu/4ozJ/VxseuzhKon
# OOhLMB8GA1UdIwQYMBaAFCM0+NlSRnAK7UD7dvuzK7DDNbMPMFQGA1UdHwRNMEsw
# SaBHoEWGQ2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3Rz
# L01pY3Jvc29mdFRpbWVTdGFtcFBDQS5jcmwwWAYIKwYBBQUHAQEETDBKMEgGCCsG
# AQUFBzAChjxodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jv
# c29mdFRpbWVTdGFtcFBDQS5jcnQwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZI
# hvcNAQEFBQADggEBAAHUesgSM5gcsDCw++6r3TlkG7E27ohjvqBPXqCHrZlfcXQ/
# NSXMHonyC6N7MeYOK45oOPiCDtm6IgH+9BK5gxpi0yP54KdSvJLdLaihEOfrR84W
# vQuTOmJKdVTUTq8w5xhXKraWjjI0cB3tYVa47N1Tw2ysXKgCQ3GYYWzmuE5wfIBU
# jKfmOOp6zcDvVkMPAw6JyDpwHZrHVB1jezHy5hahIts6CKsESpPMYeL8SjGmHfQG
# rW9jS8BNnBJE4KmGxgvr9/grRMt2m8XwFvAc8yh3rcDNI+eElMI1lyB96BXxq+Eh
# dBZHe2Kw2ssXaxCoqeBmPh9a1B/sH7UdLdxshJEwggTsMIID1KADAgECAhMzAAAB
# Cix5rtd5e6asAAEAAAEKMA0GCSqGSIb3DQEBBQUAMHkxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBMB4XDTE1MDYwNDE3NDI0NVoXDTE2MDkwNDE3NDI0NVowgYMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNVBAsTBE1PUFIx
# HjAcBgNVBAMTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAJL8bza74QO5KNZG0aJhuqVG+2MWPi75R9LH7O3HmbEm
# UXW92swPBhQRpGwZnsBfTVSJ5E1Q2I3NoWGldxOaHKftDXT3p1Z56Cj3U9KxemPg
# 9ZSXt+zZR/hsPfMliLO8CsUEp458hUh2HGFGqhnEemKLwcI1qvtYb8VjC5NJMIEb
# e99/fE+0R21feByvtveWE1LvudFNOeVz3khOPBSqlw05zItR4VzRO/COZ+owYKlN
# Wp1DvdsjusAP10sQnZxN8FGihKrknKc91qPvChhIqPqxTqWYDku/8BTzAMiwSNZb
# /jjXiREtBbpDAk8iAJYlrX01boRoqyAYOCj+HKIQsaUCAwEAAaOCAWAwggFcMBMG
# A1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBSJ/gox6ibN5m3HkZG5lIyiGGE3
# NDBRBgNVHREESjBIpEYwRDENMAsGA1UECxMETU9QUjEzMDEGA1UEBRMqMzE1OTUr
# MDQwNzkzNTAtMTZmYS00YzYwLWI2YmYtOWQyYjFjZDA1OTg0MB8GA1UdIwQYMBaA
# FMsR6MrStBZYAck3LjMWFrlMmgofMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9j
# cmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY0NvZFNpZ1BDQV8w
# OC0zMS0yMDEwLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljQ29kU2lnUENBXzA4LTMx
# LTIwMTAuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCmqFOR3zsB/mFdBlrrZvAM2PfZ
# hNMAUQ4Q0aTRFyjnjDM4K9hDxgOLdeszkvSp4mf9AtulHU5DRV0bSePgTxbwfo/w
# iBHKgq2k+6apX/WXYMh7xL98m2ntH4LB8c2OeEti9dcNHNdTEtaWUu81vRmOoECT
# oQqlLRacwkZ0COvb9NilSTZUEhFVA7N7FvtH/vto/MBFXOI/Enkzou+Cxd5AGQfu
# FcUKm1kFQanQl56BngNb/ErjGi4FrFBHL4z6edgeIPgF+ylrGBT6cgS3C6eaZOwR
# XU9FSY0pGi370LYJU180lOAWxLnqczXoV+/h6xbDGMcGszvPYYTitkSJlKOGMIIF
# vDCCA6SgAwIBAgIKYTMmGgAAAAAAMTANBgkqhkiG9w0BAQUFADBfMRMwEQYKCZIm
# iZPyLGQBGRYDY29tMRkwFwYKCZImiZPyLGQBGRYJbWljcm9zb2Z0MS0wKwYDVQQD
# EyRNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcNMTAwODMx
# MjIxOTMyWhcNMjAwODMxMjIyOTMyWjB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBD
# QTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJyWVwZMGS/HZpgICBC
# mXZTbD4b1m/My/Hqa/6XFhDg3zp0gxq3L6Ay7P/ewkJOI9VyANs1VwqJyq4gSfTw
# aKxNS42lvXlLcZtHB9r9Jd+ddYjPqnNEf9eB2/O98jakyVxF3K+tPeAoaJcap6Vy
# c1bxF5Tk/TWUcqDWdl8ed0WDhTgW0HNbBbpnUo2lsmkv2hkL/pJ0KeJ2L1TdFDBZ
# +NKNYv3LyV9GMVC5JxPkQDDPcikQKCLHN049oDI9kM2hOAaFXE5WgigqBTK3S9dP
# Y+fSLWLxRT3nrAgA9kahntFbjCZT6HqqSvJGzzc8OJ60d1ylF56NyxGPVjzBrAlf
# A9MCAwEAAaOCAV4wggFaMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFMsR6MrS
# tBZYAck3LjMWFrlMmgofMAsGA1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQAB
# MCMGCSsGAQQBgjcVAgQWBBT90TFO0yaKleGYYDuoMW+mPLzYLTAZBgkrBgEEAYI3
# FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQOrIJgQFYnl+UlE/wq4QpTlVnk
# pDBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtp
# L2NybC9wcm9kdWN0cy9taWNyb3NvZnRyb290Y2VydC5jcmwwVAYIKwYBBQUHAQEE
# SDBGMEQGCCsGAQUFBzAChjhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2Nl
# cnRzL01pY3Jvc29mdFJvb3RDZXJ0LmNydDANBgkqhkiG9w0BAQUFAAOCAgEAWTk+
# fyZGr+tvQLEytWrrDi9uqEn361917Uw7LddDrQv+y+ktMaMjzHxQmIAhXaw9L0y6
# oqhWnONwu7i0+Hm1SXL3PupBf8rhDBdpy6WcIC36C1DEVs0t40rSvHDnqA2iA6VW
# 4LiKS1fylUKc8fPv7uOGHzQ8uFaa8FMjhSqkghyT4pQHHfLiTviMocroE6WRTsgb
# 0o9ylSpxbZsa+BzwU9ZnzCL/XB3Nooy9J7J5Y1ZEolHN+emjWFbdmwJFRC9f9Nqu
# 1IIybvyklRPk62nnqaIsvsgrEA5ljpnb9aL6EiYJZTiU8XofSrvR4Vbo0HiWGFzJ
# NRZf3ZMdSY4tvq00RBzuEBUaAF3dNVshzpjHCe6FDoxPbQ4TTj18KUicctHzbMrB
# 7HCjV5JXfZSNoBtIA1r3z6NnCnSlNu0tLxfI5nI3EvRvsTxngvlSso0zFmUeDord
# EN5k9G/ORtTTF+l5xAS00/ss3x+KnqwK+xMnQK3k+eGpf0a7B2BHZWBATrBC7E7t
# s3Z52Ao0CW0cgDEf4g5U3eWh++VHEK1kmP9QFi58vwUheuKVQSdpw5OPlcmN2Jsh
# rg1cnPCiroZogwxqLbt2awAdlq3yFnv2FoMkuYjPaqhHMS+a3ONxPdcAfmJH0c6I
# ybgY+g5yjcGjPa8CQGr/aZuW4hCoELQ3UAjWwz0wggYHMIID76ADAgECAgphFmg0
# AAAAAAAcMA0GCSqGSIb3DQEBBQUAMF8xEzARBgoJkiaJk/IsZAEZFgNjb20xGTAX
# BgoJkiaJk/IsZAEZFgltaWNyb3NvZnQxLTArBgNVBAMTJE1pY3Jvc29mdCBSb290
# IENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0wNzA0MDMxMjUzMDlaFw0yMTA0MDMx
# MzAzMDlaMHcxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAf
# BgNVBAMTGE1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQTCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAJ+hbLHf20iSKnxrLhnhveLjxZlRI1Ctzt0YTiQP7tGn
# 0UytdDAgEesH1VSVFUmUG0KSrphcMCbaAGvoe73siQcP9w4EmPCJzB/LMySHnfL0
# Zxws/HvniB3q506jocEjU8qN+kXPCdBer9CwQgSi+aZsk2fXKNxGU7CG0OUoRi4n
# rIZPVVIM5AMs+2qQkDBuh/NZMJ36ftaXs+ghl3740hPzCLdTbVK0RZCfSABKR2YR
# JylmqJfk0waBSqL5hKcRRxQJgp+E7VV4/gGaHVAIhQAQMEbtt94jRrvELVSfrx54
# QTF3zJvfO4OToWECtR0Nsfz3m7IBziJLVP/5BcPCIAsCAwEAAaOCAaswggGnMA8G
# A1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFCM0+NlSRnAK7UD7dvuzK7DDNbMPMAsG
# A1UdDwQEAwIBhjAQBgkrBgEEAYI3FQEEAwIBADCBmAYDVR0jBIGQMIGNgBQOrIJg
# QFYnl+UlE/wq4QpTlVnkpKFjpGEwXzETMBEGCgmSJomT8ixkARkWA2NvbTEZMBcG
# CgmSJomT8ixkARkWCW1pY3Jvc29mdDEtMCsGA1UEAxMkTWljcm9zb2Z0IFJvb3Qg
# Q2VydGlmaWNhdGUgQXV0aG9yaXR5ghB5rRahSqClrUxzWPQHEy5lMFAGA1UdHwRJ
# MEcwRaBDoEGGP2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1
# Y3RzL21pY3Jvc29mdHJvb3RjZXJ0LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYB
# BQUHMAKGOGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljcm9z
# b2Z0Um9vdENlcnQuY3J0MBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEB
# BQUAA4ICAQAQl4rDXANENt3ptK132855UU0BsS50cVttDBOrzr57j7gu1BKijG1i
# uFcCy04gE1CZ3XpA4le7r1iaHOEdAYasu3jyi9DsOwHu4r6PCgXIjUji8FMV3U+r
# kuTnjWrVgMHmlPIGL4UD6ZEqJCJw+/b85HiZLg33B+JwvBhOnY5rCnKVuKE5nGct
# xVEO6mJcPxaYiyA/4gcaMvnMMUp2MT0rcgvI6nA9/4UKE9/CCmGO8Ne4F+tOi3/F
# NSteo7/rvH0LQnvUU3Ih7jDKu3hlXFsBFwoUDtLaFJj1PLlmWLMtL+f5hYbMUVbo
# nXCUbKw5TNT2eb+qGHpiKe+imyk0BncaYsk9Hm0fgvALxyy7z0Oz5fnsfbXjpKh0
# NbhOxXEjEiZ2CzxSjHFaRkMUvLOzsE1nyJ9C/4B5IYCeFTBm6EISXhrIniIh0EPp
# K+m79EjMLNTYMoBMJipIJF9a6lbvpt6Znco6b72BJ3QGEe52Ib+bgsEnVLaxaj2J
# oXZhtG6hE6a/qkfwEm/9ijJssv7fUciMI8lmvZ0dhxJkAj0tr1mPuOQh5bWwymO0
# eFQF1EEuUKyUsKV4q7OglnUa2ZKHE3UiLzKoCG6gW4wlv6DvhMoh1useT8ma7kng
# 9wFlb4kLfchpyOZu6qeXzjEp/w7FW1zYTRuh2Povnj8uVRZryROj/TGCBKEwggSd
# AgEBMIGQMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xIzAh
# BgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBAhMzAAABCix5rtd5e6as
# AAEAAAEKMAkGBSsOAwIaBQCggbowGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFFWG
# lVQ4oYgaLv1WyPc9AKRug5Q4MFoGCisGAQQBgjcCAQwxTDBKoCiAJgB1AHQAaQBs
# AHMAXwByAGUAcABvAHIAdABpAG4AZwAuAHAAcwAxoR6AHGh0dHA6Ly9zdXBwb3J0
# Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEBBQAEggEAQHJnDg8FhvoCRFMSYZID
# 67JcldtzIflVk0pIRoCYrLtTxB8atA9ZykH+qRSaKGMliRGr6W7yVjVtBjMfaY2b
# /sifKe2kZuFnjcamOuW8qV9GVngMZFbKaX5wE+8GoPpSOP+UVl3CWggkDuS0/Gx5
# pogq5VsDKuIidbcbnekg6TK58OvbENdsUQlXBp/SVPD3woeB+Z98QMu+9NLQycKt
# b/501eMBoc5EIimAlLIL1zXHusRZ591L7GK/hDPCJ2Qet3PRdsZyHAXoOBK+Fgnw
# XQKy5pabFaCU9iWWok7zfsiQOpc8Z7eFuztv4HVpFwdrSBJ65zdVgv36ZyJTenTm
# OKGCAigwggIkBgkqhkiG9w0BCQYxggIVMIICEQIBATCBjjB3MQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBQQ0ECEzMAAACKV+qJo0nri+gAAAAAAIowCQYFKw4DAhoFAKBdMBgG
# CSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1MTIxNzA4
# NTMwNVowIwYJKoZIhvcNAQkEMRYEFKezS9rMZi2JlKGBqxxgv7/YZ4fIMA0GCSqG
# SIb3DQEBBQUABIIBADvZVlhN991kbgU2o09T6dPRdiis5DS/q+PPV1LajsuknIqY
# 224rVUkhwXZx+3bO2FpYTQyCdfpdAja6AtS6Iz5b3HdzQmcYW9u2IApUhYDfoaQ6
# c+wrJGbXCYKlnUlYrV0xQnhoYGc9KGqJdnRtxwIgN6txCI04PZf/4IOGYDHJO9B/
# 7V8bCfak26r0L/BsWFD2gHSst/t+i8DJWeGuHa3sbKBgTyeyGStxAtXueo/e2Mmw
# YiRy6O+JWECeI2grRSt3cr+dEE5rAj/Jws3VYCbsTeVOYspkE6GqFhtiTKwsTIJw
# 4l2s4Ugrw/tdzjdOY9sIyWMRTWmJV7qtXAxTulQ=
# SIG # End signature block
