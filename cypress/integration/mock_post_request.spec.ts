// cypress/integration/mock_post_request_spec.ts
// integration tests for mocking POST request with preflight OPTIONS

describe('Mock POST request with preflight OPTIONS', () => {
  const url = 'https://gx0cvbpic9.execute-api.us-east-2.amazonaws.com/dev/';
  const payload = { websiteId: 'www.chihtingyeh.com', action: 'increment' };
  let initialCount: number;

  beforeEach(() => {
    // Send a GET request to retrieve the initial count
    cy.request(`${url}?websiteId=${payload.websiteId}&action=${payload.action}`)
      .then((response) => {
        initialCount = parseInt(response.body.count);
      });
    // Mock the preflight OPTIONS request
    cy.intercept('OPTIONS', url, (req) => {
      req.reply((res) => {
        res.headers['Access-Control-Allow-Origin'] = '*';
        res.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS';
        res.headers['Access-Control-Allow-Headers'] = 'Content-Type';
        res.statusCode = 204;
      });
    });
  });

  it('should increment the count by 1 or stay the same', () => {
    cy.request({
      method: 'POST',
      url: url,
      body: payload,
      headers: {
        'Content-Type': 'application/json',
      },
    }).then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('message', 'Visitor count incremented.');
      expect(parseInt(response.body.count)).to.be.gte(initialCount);
    });
  });
});
