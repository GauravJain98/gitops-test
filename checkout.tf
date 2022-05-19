resource "kubernetes_namespace" "portal-backend-uat" {
  metadata {
    name = "portal-backend-uat"
  }
}


resource "kubernetes_deployment" "portal-backend-uat" {
  metadata {
    name      = "portal-backend-uat"
    namespace = kubernetes_namespace.portal-backend-uat.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "portal-backend-uat"
      }
    }
    template {
      metadata {
        labels = {
          app = "portal-backend-uat"
        }
      }
      spec {
        container {
          image = "430029778150.dkr.ecr.us-east-1.amazonaws.com/pn-portal-backend:8c9b447fdd150cb12cdcf708c8f74fe16f99ee7c"

          name  = "portal-backend-uat"
          port {
            container_port = 3000
          }
          env {
            name = "MONGODB_URL"
            value = var.mongodb_url
          }
          env {
            name = "SMTP_HOST"
            value = var.smtp_host
          }
          env {
            name = "SMTP_USERNAME"
            value = var.smtp_username
          }
          env {
            name = "SMTP_PASSWORD"
            value = var.smtp_password
          }
          env {
            name = "SMTP_PORT"
            value = var.smtp_port
          }
          env {
            name = "EMAIL_FROM"
            value = var.smtp_email_from
          }
          env {
            name = "JWT_SECRET"
            value = var.jwt_secret
          }
          env {
            name = "APP_BASE_URL"
            value = var.app_base_url
          }
          env {
            name = "API_BASE_URL"
            value = var.api_base_url
          }
          env {
            name = "API_GATEWAY_URL"
            value = var.api_gateway_url
          }
          env {
            name = "API_GATEWAY_KEY"
            value = var.api_gateway_key
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "portal-backend-uat" {
  metadata {
    name      = kubernetes_deployment.portal-backend-uat.spec.0.template.0.metadata.0.labels.app
    namespace = kubernetes_namespace.portal-backend-uat.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.portal-backend-uat.spec.0.template.0.metadata.0.labels.app
    }
    type = "ClusterIP"
    port {
      port        = 80
      target_port = 3000
    }
  }
}
resource "kubernetes_ingress" "portal-backend-uat" {
  metadata {
    name      = kubernetes_deployment.portal-backend-uat.spec.0.template.0.metadata.0.labels.app
    namespace = kubernetes_namespace.portal-backend-uat.metadata.0.name
    annotations = {
      "cert-manager.io/cluster-issuer" = "cert-manager"
    }
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts = ["portal-api.uat.pinknode.io"]
      secret_name = "portal-backend-uat-tls"
    }
    rule {
      host = "portal-api.uat.pinknode.io"
      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_service.portal-backend-uat.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }
}
