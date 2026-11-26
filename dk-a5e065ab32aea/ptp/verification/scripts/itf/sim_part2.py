

import sys

if len(sys.argv) != 2:
    print("give the correct input")
    sys.exit(1)

speed_size = sys.argv[1].upper()
print(speed_size)
values = ["10G", "25G", "50G", "100G"]

if speed_size in values:
    pass
else:
    print("give correct input")
    print('Input argument should be in ["10g","25g","50g","100g","10G","25G","50G","100G"]')
    
    sys.exit(1)


import os
import glob
import re
import json
import time
import subprocess
import smtplib
from pathlib import Path
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from datetime import datetime
from collections import defaultdict

curr_dir="/p/psg/pac/release/main/github/psgpac/sed/regression_test/simulation/1588_ptp_agx5_sm72plus/"+speed_size.lower()+"_non_anlt/applications.fpga.system-example-designs.sm7plus-ed-ptp//src/hw/verification/scripts/itf"

OUT_DIR = curr_dir
OUT_DIR_PATH = [
    Path(curr_dir)
]

DIGIT_LINE = re.compile(r"^\d+$")
SIM_ARC_JOB_ID_PATTERN = re.compile(r"# ARC Job Id: (\d+)")
TEST_SPETC_ID_PATTERN = re.compile(r"The SPeTC test run ID is (\d+)")

SM7PLUSPTPSimTestData = {
    'Devkit': {
        'SM7PLUS_PTP-PDK': {'SIM_ARC_Job_Id': None, 'SIM_Duration': '0h 0m 0s', 'Test_Executed': 'NO', 'Test_Total': 0, 'Test_Passed': 0, 'Test_Failed': 0, 'Test_Runtime': '0h 0m 0s', 'Test_ARC_Job_Id': None, 'Test_SPeTC_Id': None, 'Comments': None}
    },
    'Data': {'Email_Report': False}
}

class SM7PLUSPTPSimTest:
    def __init__(self,report_path) -> None:
        self.report_path = report_path
        self.report_file = None
        self.devkit = SM7PLUSPTPSimTestData['Devkit']

    def generate_html_report(self, project_name) -> None:
        self.report_file = open(self.report_path, "w")
        self.report_file.write(f"""<!DOCTYPE html>
        <html>
        <head>
            <title>{project_name} - Test Report</title>
            <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet">
            <style>
                body {{
                    font-family: 'Roboto', Arial, sans-serif;
                    margin: 20px;
                }}
                h2 {{
                    color: #003366 ; /* Navy blue color */
                    text-align: left; /* Center the text */
                    font-size: 25px; /* Increase font size */
                    font-weight: bold; /* Make the text bold */
                }}
                #resultTable {{
                    table-layout: auto;
                    width: auto;
                    height: auto;
                    white-space: nowrap;
                    padding: 4px;
                }}
                .pass-cell {{ background-color: #00FF00; font-weight: bold; color: #003366 }}
                .fail-cell {{ background-color: #FF0000; font-weight: bold; color: white }}
                .not_run-cell {{ background-color: #FFD700; font-weight: bold; color: #003366}}
            </style>
        </head>
        <body>

        <h2>{project_name}</h2>
        """)

        # Get current date and time
        now = datetime.now()

        # Run the Linux date command with custom formatting
        command = ["date", "+%a, %d-%b-%Y and %I:%M:%S %p %Z"]
        result = subprocess.run(command, capture_output=True, text=True)

        # Output the result of the command
        date_time_str = result.stdout.strip()

        # Split the output into date and time parts
        date_part, time_part = date_time_str.split(' and ')
        self.report_file.write(f'<h2 style="font-size: 12px;font-weight: normal">Report generated on {date_part} at {time_part}</h2>')

        if SM7PLUSPTPSimTestData['Data']['Email_Report'] == True:
            self.report_file.write(
                '<table id="summaryTable1" cellpadding="0" cellspacing="0" border="0" '
                'style="table-layout: fixed; border-collapse: collapse; width: 1050px; background-color: #00008B; '
                'text-align: center; font-size: 14px; color: white; box-sizing: border-box;">'

                '<colgroup>'
                    '<col style="width: 70px;">'
                    '<col style="width: 50px;">'
                    '<col style="width: 50px;">'
                    '<col style="width: 50px;">'
                    '<col style="width: 50px;">'
                    '<col style="width: 50px;">'
                    '<col style="width: 50px;">'
                    '<col style="width: 50px;">'
                    '<col style="width: 50px;">'
                    '<col style="width: 50px;">'
                    '<col style="width: 265px;">'
                '</colgroup>'

                '<thead>'
                    '<tr>'
                        '<th rowspan="2" style="border: 1px solid white; border-top: 2px solid orange; border-bottom: 2px solid orange; padding: 4px 4px; padding: 4px 4px; box-sizing: border-box;">SED</th>'
                        '<th colspan="2" style="border: 1px solid white; border-top: 2px solid orange; padding: 4px 4px; box-sizing: border-box;">Simulation</th>'
                        '<th colspan="7" style="border: 1px solid white; border-top: 2px solid orange; padding: 4px 4px; box-sizing: border-box;">Test Suite</th>'
                        '<th rowspan="2" style="border: 1px solid white; border-top: 2px solid orange; border-bottom: 2px solid orange; padding: 4px 4px; padding: 4px 4px; box-sizing: border-box;">Comments</th>'
                    '</tr>'

                    '<tr>'
                        '<th style="border: 1px solid white; border-bottom: 2px solid orange; padding: 4px 4px; padding: 4px 4px; box-sizing: border-box;">ARC Job Id</th>'
                        '<th style="border: 1px solid white; border-bottom: 2px solid orange; padding: 4px 4px; padding: 4px 4px; box-sizing: border-box;">Duration</th>'
                        '<th style="border: 1px solid white; border-bottom: 2px solid orange; padding: 4px 4px; padding: 4px 4px; box-sizing: border-box;">Executed</th>'
                        '<th style="border: 1px solid white; border-bottom: 2px solid orange; padding: 4px 4px; padding: 4px 4px; box-sizing: border-box;">ARC Job Id</th>'
                        '<th style="border: 1px solid white; border-bottom: 2px solid orange; padding: 4px 4px; padding: 4px 4px; box-sizing: border-box;">SPeTC Id</th>'
                        '<th style="border: 1px solid white; border-bottom: 2px solid orange; padding: 4px 4px; padding: 4px 4px; box-sizing: border-box;">Runtime</th>'
                        '<th style="border: 1px solid white; border-bottom: 2px solid orange; padding: 4px 4px; padding: 4px 4px; box-sizing: border-box;">Total</th>'
                        '<th style="border: 1px solid white; border-bottom: 2px solid orange; padding: 4px 4px; padding: 4px 4px; box-sizing: border-box;">Failed</th>'
                        '<th style="border: 1px solid white; border-bottom: 2px solid orange; padding: 4px 4px; padding: 4px 4px; box-sizing: border-box;">Pass Rate</th>'
                    '</tr>'
                '</thead>'
            )

            for variant, variant_root in SM7PLUSPTPSimTestData.items():
                if variant == 'Data':
                    continue
                #for design, design_root in variant_root.items():
                for i, (design, design_root) in enumerate(variant_root.items()):
                    total_tests = len(variant_root)
                    is_last_row = (i == total_tests - 1)
                    border_bottom_style = "2px solid orange" if is_last_row else "1px solid orange"
                    self.report_file.write(
                        f'<tr style="background-color: #ADD8E6; font-size: 13px; color: #003366;">'
                        f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center">{design.replace("-", "&#8209;")}</td>'
                    )
                                        
                    sim_arc_job_id = self.devkit[design]['SIM_ARC_Job_Id']
                    if sim_arc_job_id in ['None',None]:
                        self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center;">{sim_arc_job_id}</td>')
                    else:
                        arc_job_id_url = f'<a href="https://sc-arc.sc.altera.com/arc/dashboard/reports/show_job/{sim_arc_job_id}" target="_blank" style="text-decoration: none">{sim_arc_job_id}</a>'
                        self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center;">{arc_job_id_url}</td>')

                    sim_duration = self.devkit[design]['SIM_Duration']
                    self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center;">{sim_duration}</td>')

                    test_executed = self.devkit[design]['Test_Executed']
                    color = "green" if test_executed == 'YES' else "red"
                    self.report_file.write(
                        f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center; color: {color}; font-weight: bold;">{test_executed.replace("-", "&#8209;")}</td>'
                    )

                    test_arc_job_id = self.devkit[design]['Test_ARC_Job_Id']
                    if test_arc_job_id in ['None',None]:
                        self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center">{test_arc_job_id}</td>')
                    else:
                        arc_job_id_url = f'<a href="https://sc-arc.sc.altera.com/arc/dashboard/reports/show_job/{test_arc_job_id}" target="_blank" style="text-decoration: none">{test_arc_job_id}</a>'
                        self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center;">{arc_job_id_url}</td>')

                    test_spetc_id = self.devkit[design]['Test_SPeTC_Id']
                    if test_spetc_id in ['None',None]:
                        self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center;">{test_spetc_id}</td>')
                    else:
                        spetc_id_url = f'<a href="https://spetc.altera.com/testsummary?testRunIds={test_spetc_id}" target="_blank" style="text-decoration: none">{test_spetc_id}</a>'
                        self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center">{spetc_id_url}</td>')

                    test_runtime = self.devkit[design]['Test_Runtime']
                    self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center">{test_runtime}</td>')

                    test_total = self.devkit[design]['Test_Total']
                    self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center;">{test_total}</td>')

                    test_failed = self.devkit[design]['Test_Failed']
                    color = "green" if test_failed > 0 else "red"
                    background_color, color = ('#FF0000', 'white') if test_failed > 0 else ('#ADD8E6', '#003366')
                    self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center; background-color: {background_color}; color: {color};font-weight: bold;">{test_failed}</td>')

                    test_passed = self.devkit[design]['Test_Passed']
                    if test_passed != 0:
                        pass_rate=(test_passed/test_total)*100
                    else:
                        pass_rate=0
                    print(f'Pass_rate: {pass_rate}')
                    print(f'test_total: {test_total}')

                    if pass_rate == 100: 
                        self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center; background-color: #00FF00; color: #000000; font-weight: bold;">{pass_rate:.2f}%</td>')
                    elif pass_rate >= 0 and pass_rate < 100:
                        self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center; background-color: #FFD700; color: #000000; font-weight: bold;">{pass_rate:.2f}%</td>')
                    elif test_total == 0:
                        self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; border-right: 1px solid orange; padding: 4px 4px;text-align: center; font-weight: bold;">{pass_rate:.2f}%</td>')

                    comments = self.devkit[design]['Comments']
                    if comments in ['None', None]:
                        self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; padding: 4px 4px;text-align: center">{comments}</td>')
                    else:
                        color, font_size = ('#003366','12px') if comments == 'Tests not available' else ('red','12px')
                        self.report_file.write(f'<td style="border: 1px solid white; border-bottom: {border_bottom_style}; padding: 4px 4px;text-align: center font-size: {font_size}; color: {color}; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">{comments.replace("-", "&#8209;")}</td>')
                    self.report_file.write("</tr>")
            
        self.report_file.write("</table>")
        self.report_file.write("</tbody></table></body></html>")
        self.report_file.close()

    def extract_from_logs(self,folder_path):
        results = {}

        for file in glob.glob(os.path.join(folder_path, "*"+speed_size+"_STDOUT.out")):
            extracted = []
            with open(file, "r") as f:
                lines = f.readlines()

            i = 0
            while i < len(lines):
                line = lines[i].strip()
                
                # 1. Extract Simulation ARC Job Id
                match = SIM_ARC_JOB_ID_PATTERN.search(line)
                if match:
                    extracted.append(("# ARC Job Id:", match.group(1)))
                    i += 1
                    continue

                # 2. Extract Test ARC Job Id
                if line == "Submitting scripts/itf --regr_cfg=sanity_regr":
                    if i + 1 < len(lines):
                        next_line = lines[i+1].strip()
                        if DIGIT_LINE.fullmatch(next_line):
                            extracted.append(("Submitting scripts/itf --regr_cfg=sanity_regr", next_line))
                    i += 2
                    continue
                
                # 3. Extract Test SPeTC Id
                match = TEST_SPETC_ID_PATTERN.search(line) 
                if match:
                    extracted.append(("The SPeTC test run ID is", match.group(1)))
                    i += 1
                    continue

                i += 1

            results[file] = extracted

        return results

    # Convert defaultdicts to normal dicts before printing
    def convert(self, d):
        if isinstance(d, defaultdict):
            return {k: convert(v) for k, v in d.items()}
        else:
            return d

    def convert_duration(self, hms_str):
        # Parse the input string into a datetime.time object
        time_obj = datetime.strptime(hms_str, "%H:%M:%S").time()
        
        # Extract hours, minutes, and seconds
        hours = time_obj.hour
        minutes = time_obj.minute
        seconds = time_obj.second

        # Format as "Xh Ym Zs"
        return f"{hours}h {minutes}m {seconds}s"

    def update_test_results(self, design, arc_job_id, flag):
        if flag == 'SIM':
            print(f'Flag: Construct simulation : arc_job_id -> {arc_job_id}')
            run_cmd = f'/p/psg/ctools/arc/2019.1/bin/arc job-info {arc_job_id} elapsed_time'
            process = subprocess.run(run_cmd, shell=True, executable="/bin/bash", capture_output=True, text=True)
            if process.returncode != 0:
                print(f'<FAILED: to get child arc jobs {process.returncode}>')
                    
            seconds = process.stdout.strip().splitlines()
            print(f'seconds: {seconds} - {seconds[0]} -> type : {type(seconds)}')
            if seconds and seconds[0] not in ("", 0, "0"):
                print('inside construct simulation seconds')
                duration = f"{int(seconds[0])//3600:02d}:{(int(seconds[0])%3600)//60:02d}:{int(seconds[0])%60:02d}"
                SM7PLUSPTPSimTestData['Devkit'][design]['SIM_Duration'] = self.convert_duration(duration)
        else:
            print(f'Flag: Test simulation: arc_job_id -> {arc_job_id}')
            run_cmd = f'/p/psg/ctools/arc/2019.1/bin/arc job-query parent={arc_job_id}'
            process = subprocess.run(run_cmd, shell=True, executable="/bin/bash", capture_output=True, text=True)
            if process.returncode != 0:
                print(f'<FAILED: to get child arc jobs {process.returncode}>')
            arc_jobid_list = process.stdout.strip().splitlines()
            
            # Read runtime
            run_cmd = f'/p/psg/ctools/arc/2019.1/bin/arc job-info {arc_job_id} elapsed_time'
            process = subprocess.run(run_cmd, shell=True, executable="/bin/bash", capture_output=True, text=True)
            if process.returncode != 0:
                print(f'<FAILED: to get child arc jobs {process.returncode}>')
            
            seconds = process.stdout.strip().splitlines()
            print(f'seconds: {seconds} - {seconds[0]} -> type : {type(seconds)}')
            if seconds and seconds[0] not in ("", 0, "0"):
                print('inside test simulation seconds')
                runtime = f"{int(seconds[0])//3600:02d}:{(int(seconds[0])%3600)//60:02d}:{int(seconds[0])%60:02d}"
                SM7PLUSPTPSimTestData['Devkit'][design]['Test_Runtime'] = self.convert_duration(runtime)
            
            # Get job status
            total = 0
            passed = 0
            failed = 0
            
            for job_id in arc_jobid_list:
                time.sleep(2)
                run_cmd = f'/p/psg/ctools/arc/2019.1/bin/arc job-info {job_id} status'
                process = subprocess.run(run_cmd, shell=True, executable="/bin/bash", capture_output=True, text=True)
                if process.returncode != 0:
                    print(f'<FAILED: to get child arc jobs {process.returncode}>')
                result = process.stdout.strip().splitlines()
                if result[0] == "passed":
                    total, passed, failed = total + 1, passed + 1, failed
                elif result[0] == "failed":
                    total, passed, failed = total + 1, passed, failed + 1
                print(f'Design->{design} Result->{result[0]} Total->{total} Passed->{passed} Failed->{failed}')

            SM7PLUSPTPSimTestData['Devkit'][design]['Test_Total'] = total
            SM7PLUSPTPSimTestData['Devkit'][design]['Test_Passed'] = passed
            SM7PLUSPTPSimTestData['Devkit'][design]['Test_Failed'] = failed

    def send_report_email(self, build_date, html_report, sender, receivers) -> None:
        msg = MIMEMultipart('alternative')
        msg['Subject'] = f'SM7PLUS_PTP Simulation Automated Test: {build_date}'
        msg['From'] = sender
        msg['To'] = ','.join(receivers)
        #msg['To'] = receivers

        html_content=Path(html_report).read_text()
        body = MIMEText(html_content, 'html','utf-8')
        msg.attach(body)

        try:
            smtp = smtplib.SMTP('localhost')
            smtp.set_debuglevel(1)
            refused=smtp.sendmail(sender, receivers, msg.as_string())
            smtp.quit()
            if refused:                                                
                print("[ERROR] These emails were refused:")
                for email, (code, message) in refused.items():
                    print(f"  {email} -> {code}: {message.decode('utf-8', errors='ignore')}")
            else:
                print("[INFO] SMTP accepted all recipients:")
                for email in receivers:
                    print(f"  OK: {email}")
                    print("[INFO] If mail not received, check mailq / spam / relay")
                    print ('[INFO] Sending report mail [success]')
        except smtplib.SMTPException as e:
            print("[ERROR] Failed to send email:", e)

if __name__ == "__main__":
    current_date = datetime.now().strftime('%Y%m%d')
    html_report=f'{OUT_DIR}/sm7plus_simulation_test.html'
    report = SM7PLUSPTPSimTest(html_report)

    for d in OUT_DIR_PATH:
        # Extract ARC Job Id and SPeTC Id from the out file
        output = report.extract_from_logs(d)
        print(f'output: {output}')
        # Update the information
        for fname, items in output.items():
            print(f'file_name: {fname}')
            parts = os.path.basename(fname).rsplit('.',1)[0].split('SIM_SED_SM7PLUSPTP_')[1].split('_')
            print(f'parts: {parts}')
            design = f'SM7PLUS_PTP-{parts[0]}'
            #design = '-'.join([parts[0].capitalize()] + ([parts[1].upper()] if len(parts) > 1 else []) + (parts[2:] if len(parts) > 2 else []))
            print(f'design: {design}')
            if design in ['SM7PLUS_PTP-PDK']:
                print('debug1')
                for key, value in items:
                    print(f'key->value: {key}->{value}')
                    if key == '# ARC Job Id:':
                        SM7PLUSPTPSimTestData['Devkit'][design]['SIM_ARC_Job_Id'] = value
                        SM7PLUSPTPSimTestData['Devkit'][design]['Test_Executed'] = 'YES'
                        SM7PLUSPTPSimTestData['Data']['Email_Report'] = True
                        if value is not ['None',None]:
                            print(f'Value -> {value}')
                            report.update_test_results(design,value,"SIM")
                    elif key == 'Submitting scripts/itf --regr_cfg=sanity_regr':
                        SM7PLUSPTPSimTestData['Devkit'][design]['Test_ARC_Job_Id'] = value
                        SM7PLUSPTPSimTestData['Devkit'][design]['Test_Executed'] = 'YES'
                        SM7PLUSPTPSimTestData['Data']['Email_Report'] = True
                        if value is not ['None',None]:
                            print(f'Value -> {value}')
                            report.update_test_results(design,value,"TEST")
                    elif key == 'The SPeTC test run ID is':
                        SM7PLUSPTPSimTestData['Devkit'][design]['Test_SPeTC_Id'] = value
                        SM7PLUSPTPSimTestData['Devkit'][design]['Test_Executed'] = 'YES'
                        SM7PLUSPTPSimTestData['Data']['Email_Report'] = True

    # Generate report
    report.generate_html_report(f"SM7PLUS_PTP_{parts[1]} Simulation Report")

    if SM7PLUSPTPSimTestData['Data']['Email_Report']:
        sender = 'no-reply <no-reply@intel.com>'
        email_addr = ['dinesh.babu.rajarathinam@altera.com','ipsita.das@altera.com','nanditha.jayarajan@altera.com','yerriswamy.gunda@altera.com']
        report.send_report_email(current_date, html_report, sender, email_addr)

    print(json.dumps(report.convert(SM7PLUSPTPSimTestData), indent=4))
