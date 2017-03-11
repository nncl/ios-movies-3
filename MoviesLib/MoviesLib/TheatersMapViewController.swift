//
//  TheatersMapViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 11/03/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit

class TheatersMapViewController: UIViewController {
    
    var elementName: String! // Sabemos qual elemento está na linha que está sendo lida
    var theater: Theater!
    var theaters: [Theater] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadXML();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loadXML() {
        // Vamos garantir que não será nulo. ex: nome errado de arquivo
        // e criar parser
        if let xmlURL = Bundle.main.url(forResource: "theaters", withExtension: "xml"), let xmlParser = XMLParser(contentsOf: xmlURL) {
            
            // XML content already gotten
            // In here we already have the XML File content
            
            // Let's parse it
            // Define who is its delegate
            // And implement XML deletage protocol
            xmlParser.delegate = self
            xmlParser.parse()
            
        }
    }

}

extension TheatersMapViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("Start", elementName)
        self.elementName = elementName
        
        if elementName == "Theater" {
            theater = Theater()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // print("Content", string)
        
        // Remove blank spaces
        let content = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !content.isEmpty {
            print("Content", content)
            
            switch elementName {
            case "name":
                theater.name = content
            case "address":
                theater.address = content
            case "latitude":
                theater.latitude = Double(content)
            case "longitude":
                theater.longitude = Double(content)
            case "url":
                theater.url = content
            default:
                break // We do not want to do anything in this moment right now
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("End", elementName)
        
        if elementName == "Theater" {
            theaters.append(theater)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        // TODO add to the map
        print("Total", theaters.count)
    }
}

















