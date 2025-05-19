import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["startDate", "endDate", "downloadButton"]

  connect() {
    console.log('download consent controller connected')
  }
  
  download() {
    console.log('download avviato')
    const startDate = this.startDateTarget.value
    const endDate = this.endDateTarget.value
    
    if (startDate && endDate && new Date(startDate) > new Date(endDate)) {
      alert('La data di inizio deve essere precedente alla data di fine')
      return
    }
    
    // Costruisci l'URL con i parametri di query
    let downloadUrl = '/panel/settings/download-consents'
    const params = []
    
    if (startDate) {
      params.push(`start_date=${startDate}`)
    }
    
    if (endDate) {
      params.push(`end_date=${endDate}`)
    }
    
    if (params.length > 0) {
      downloadUrl += `?${params.join('&')}`
    }
    
    // Esegui il download
    window.location.href = downloadUrl
  }
}