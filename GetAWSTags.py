import boto3
import argparse
import csv

# https://aws.amazon.com/blogs/architecture/how-to-efficiently-extract-and-query-tagged-resources-using-the-aws-resource-tagging-api-and-s3-select-sql/

field_names = ['ResourceArn', 'TagKey', 'TagValue']

def writeToCsv(writer, args, tag_list):
    for resource in tag_list:
        #print("Extracting tags for resource: " +
        #      resource['ResourceARN'] + "...")
        for tag in resource['Tags']:
            row = dict(
                ResourceArn=resource['ResourceARN'], TagKey=tag['Key'], TagValue=tag['Value'])
            writer.writerow(row)

def input_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True,
                        help="Output CSV file (eg, /tmp/tagged-resources.csv)")
    return parser.parse_args()

def getRegions():
    client = boto3.client('ssm')

    response = client.get_parameters_by_path(
        Path='/aws/service/global-infrastructure/regions'
    )

    return response['Parameters']
    

def main():

    resultsFile = '/mnt/c/DevArea/da-CloudTagging/results_aws.csv'
    # args = input_args()
    with open(resultsFile, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, quoting=csv.QUOTE_ALL,
                                delimiter=',', dialect='excel', fieldnames=field_names)
        writer.writeheader()

        for region in getRegions():
            print(region['Value'])
            try:
                restag = boto3.client('resourcegroupstaggingapi', region_name=region['Value'])

                response = restag.get_resources(ResourcesPerPage=50)
                writeToCsv(writer, resultsFile, response['ResourceTagMappingList'])
                while 'PaginationToken' in response and response['PaginationToken']:
                    token = response['PaginationToken']
                    response = restag.get_resources(
                        ResourcesPerPage=50, PaginationToken=token)
                    writeToCsv(writer, resultsFile, response['ResourceTagMappingList'])
            except Exception as e:
                print(e)

if __name__ == '__main__':
    main()