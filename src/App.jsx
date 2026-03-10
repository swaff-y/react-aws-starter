import { Container, Row, Col, Button } from 'react-bootstrap'

function App() {
  return (
    <Container className="mt-5">
      <Row className="justify-content-center">
        <Col md={8} className="text-center">
          <h1>Pheonix</h1>
          <p className="lead">React + Bootstrap project is ready.</p>
          <Button variant="primary">Get Started</Button>
        </Col>
      </Row>
    </Container>
  )
}

export default App
