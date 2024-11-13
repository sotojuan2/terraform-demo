package terraform.policy

import future.keywords.if

# By default, deny requests
default allow := false

# Allow rule: grants permission if user is admin and API key matches

#default allow := false

# Allow admins to do anything.
#allow if user_is_admin

# user_is_admin is true if "admin" is among the user's roles as per data.user_roles
#user_is_admin if "admin" in data.user_roles[input.variables.confluent_cloud_api_key.value]

allow if {
    #input.variables.confluent_cloud_api_key.value == valid_api_key
    input.variables.confluent_cloud_api_key.value == data.users[_].key
    data.users[_].role == "admin"
    #input.variables.confluent_cloud_api_secret.value == valid_api_secret
    valid_display_name_for_cluster(input.resource_changes[_])
    allow := true
    #msg := "Permite crear"
}

deny[msg] {
    input.resource_changes[_].type == "confluent_kafka_cluster"
    input.resource_changes[_].change.after.cloud != "AZURE"
    msg := "El clúster de Confluent Kafka debe estar en Azure."
}

deny[msg] {
    input.resource_changes[_].type == "confluent_kafka_cluster"
    input.resource_changes[_].change.after.region != "spaincentral"
    msg := "El clúster de Confluent Kafka debe estar en la región spaincentral."
}

deny[msg] {
    input.resource_changes[_].type == "confluent_kafka_cluster"
    startswith(input.resource_changes[_].change.after.display_name, "JSOTO") == false
    msg := "El clúster de Confluent Kafka debe empezar por JSOTO."
}


deny[msg] {
    input.resource_changes[_].type == "confluent_kafka_topic"
    startswith(input.resource_changes[_].change.after.topic_name, "shoe") == false
    msg := "Los topicos deben empezar por 'shoe'. Lo incumple el tópico: "
}

valid_display_name_for_cluster(resource) {
    resource.type == "confluent_kafka_cluster"
    startswith(resource.change.after.display_name, "JSOTO")
}